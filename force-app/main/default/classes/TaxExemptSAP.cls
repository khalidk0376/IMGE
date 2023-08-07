/**
* Class Name: TaxExemptSAP
* Created By : Rajesh Kumar 
* Created Date : 02-12-2020
* Test Class: 
* Ticket : BK-11323
* **************************************************************************************************************************
* @description : As per the new functionality i have removed all exempt code from existing and add logic with newly create table Tax_Mapping_Configuration__c for check Tax Exempt functionality.
* **************************************************************************************************************************
**/

public with sharing class TaxExemptSAP {
    // Modified by Palla Kishore for the ticket BK-19606
    public Boolean TaxExempt (String TaxCode, String TaxCountry, Double PrmaryTaxRate , Double SecondaryTaxRate) {
        Boolean isTaxExemptSAP = false;
        List<Tax_Mapping_Configuration__c> lstTaxMappingConfig = [SELECT ID , Tax_Code__c ,Tax_Country__c, Tax_Exempt__c, Primary_Tax_Rate__c , Secondary_Tax_Rate__c FROM Tax_Mapping_Configuration__c WHERE Tax_Code__c =: TaxCode AND Tax_Country__c =: TaxCountry AND Primary_Tax_Rate__c = : PrmaryTaxRate AND Secondary_Tax_Rate__c = : SecondaryTaxRate LIMIT 1];
        if(!lstTaxMappingConfig.isEmpty()){     isTaxExemptSAP = lstTaxMappingConfig[0].Tax_Exempt__c;       return isTaxExemptSAP;
        }
        return isTaxExemptSAP;
    } 
 
}