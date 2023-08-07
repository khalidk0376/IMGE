/**
 * @author Aslam Bari
 * @Modified By Akshi Bhutani On 12/19/2018 - GGCW-2855
 * @description helper to assist with retrieving the tax language from the custom settings.
 * Modified by Rajesh Kumar yadav ::: https://informa-ge-sfdc.atlassian.net/browse/BK-2006 on 8/8/19.
 * Modified by Avinash For BK-3429 08-03-2020
 * Modified by Faisal Khan for BK-25330
 */
public with sharing class TaxLanguageHelper {
    /**
    * @param string type Tax Language Code.
    * @description this Method for the Get Tax Language by code.
    * @return String Type taxLanguage.
    */
    public static Tax_Language__c getTaxLanguage(String code) {
        Tax_Language__c taxLanguage = Tax_Language__c.getValues(code);
        System.debug('TaxLanguageHelper.getTaxLanguage() code: ' + code);
        if (taxLanguage == null) {
            System.debug(LoggingLevel.WARN, 'TaxLanguageHelper.getTaxLanguage() code: [' + code + '] is not setup correctly. ');
        }
        return taxLanguage;
    }
    
    
    /**
    * @param string type Tax Language Code.
    * @description this Method for the Get Alternate Credit Language by code.
    * @return String Type taxLanguage.
    * BK-25330
    */
    public static String getLanguagealternateCreditTransfer(String code) {
       
        Tax_Language__c taxLanguage;
        if (code!= Null) {
             taxLanguage = getTaxLanguage(code);
         }
        
        if (taxLanguage != null) { if (taxLanguage.Language_2__c != null && taxLanguage.Language_2__c != '') {return taxLanguage.Language__c + taxLanguage.Language_2__c; /* GGCW-2855 */ } else { return taxLanguage.Language__c; /* GGCW-2855 */ }
        } 
        
        System.debug('TaxLanguageHelper.getTaxLanguage() code: ' + code);
        if (taxLanguage == null) {
            System.debug(LoggingLevel.WARN, 'TaxLanguageHelper.getLanguagealternateCreditTransfer() code: [' + code + '] is not setup correctly. ');
        }
        return '';
    }
        
    /**
    * @param string type legal Entity Code and string type currency Code.
    * @description this Method for the Get Tax Language by code.
    * @return String Type.
    */
    public static String getLanguageTextForCreditTransferInfo(String legalEntityCode, String currencyCode, String esaltcurrency) {
        // Modified by Rajesh Kumar yadav : https://informa-ge-sfdc.atlassian.net/browse/BK-2006 on 8/8/19.
        Tax_Language__c taxLanguage;
        if (esaltcurrency != Null) { taxLanguage = getTaxLanguage(legalEntityCode + currencyCode + esaltcurrency);} else {taxLanguage = getTaxLanguage(legalEntityCode + currencyCode);}
        // Modified by Rajesh Kumar yadav : https://informa-ge-sfdc.atlassian.net/browse/BK-2006 on 8/8/19.
        if (taxLanguage != null) { if (taxLanguage.Language_2__c != null && taxLanguage.Language_2__c != '') {return taxLanguage.Language__c + taxLanguage.Language_2__c; /* GGCW-2855 */ } else { return taxLanguage.Language__c; /* GGCW-2855 */ }
        } /*else {
             Commenting this code to avoid 151 DML governor limit exception
            if (Schema.sObjectType.Error_Log__c.isCreateable() && Schema.sObjectType.Error_Log__c.fields.Service_Source__c.isCreateable() && Schema.sObjectType.Error_Log__c.fields.Source_Name__c.isCreateable() && Schema.sObjectType.Error_Log__c.fields.Description__c.isCreateable()) {
                insert new Error_Log__c(Service_Source__c = 'Integration', Source_Name__c = 'TaxLanguageHelper', Description__c = 'The tax language code did not find a valid value in the Tax_language__c custom setting. Please rectify.');
            }*/
        return 'NoTaxLang';

    }
    /**
    * @param string type legal Entity Code and Decimal type tax Rate.
    * @description this Method for the Get Tax Language by code.
    * @return String Type.
    */
    public static String getLanguageTextForVatFooter(String legalEntityCode, Decimal taxRate) {
        System.debug('TaxLanguageHelper.getTaxLanguage() legalEntityCode: [' + legalEntityCode + ']  taxRate: [' + taxRate + ']is not setup correctly. ');
        if (taxRate == null) { taxRate = 0;
        }
        Tax_Language__c taxLanguage = getTaxLanguage(legalEntityCode + 'TR' + Integer.valueOf(taxRate));
        if (taxLanguage != null) { if (taxLanguage.Language_2__c != null && taxLanguage.Language_2__c != '') { return taxLanguage.Language__c + taxLanguage.Language_2__c; /* GGCW-2855 */ } else { return taxLanguage.Language__c;/* GGCW-2855 */ }
        }   /*else
            if ( Schema.sObjectType.Error_Log__c.isCreateable() && Schema.sObjectType.Error_Log__c.fields.Service_Source__c.isCreateable() && Schema.sObjectType.Error_Log__c.fields.Source_Name__c.isCreateable() && Schema.sObjectType.Error_Log__c.fields.Description__c.isCreateable()) {
            insert new Error_Log__c(Service_Source__c = 'Integration', Source_Name__c = 'TaxLanguageHelper', Description__c = 'The tax language code did not find a valid value in the Tax_language__c custom setting. Please rectify.');
        }*/
        return 'NoTaxLang';
    }
    
     /**
    * @param string type legal Entity Code and Decimal type tax Rate + 'MAD'
    * @description this Method for the Get Tax Language by code for Morocco
    * @return String Type.
    */
    public static String getLanguageTextForVatFooterForMAD(String legalEntityCode, Decimal taxRate) {
        System.debug('TaxLanguageHelper.getTaxLanguage() legalEntityCode: [' + legalEntityCode + ']  taxRate: [' + taxRate + ']is not setup correctly. ');
        if (taxRate == null) { taxRate = 0;
        }
        Tax_Language__c taxLanguage = getTaxLanguage(legalEntityCode + 'TR' + Integer.valueOf(taxRate) + 'MAD');
        if (taxLanguage != null) { if (taxLanguage.Language_2__c != null && taxLanguage.Language_2__c != '') { return taxLanguage.Language__c + taxLanguage.Language_2__c;}else {return taxLanguage.Language__c;}
        }  
        return 'NoTaxLang';
    }
}