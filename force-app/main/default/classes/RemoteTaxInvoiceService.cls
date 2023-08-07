/**
 * Integration point to call out to the tax service for the Invoices
 */

public with sharing class RemoteTaxInvoiceService extends RemoteTaxAbstractService implements RemoteTaxService {
    private RemoteTaxInvoiceServiceDatabaseInterface databaseInterface;
    public RemoteTaxInvoiceService() {
        databaseInterface = new RemoteTaxInvoiceServiceDatabaseDefaultImpl();
    }

    public Map<Id, blng.TaxResults> getTax(List<String> listOfInvoiceIds) {
        System.debug('RemoteTaxInvoiceService.getTax() listOfLegalEntityReferences: ' + listOfInvoiceIds);
        /*List<blng__Invoice__c> invoices = new List<blng__Invoice__c>();
        if(listOfInvoiceIds != null) {
            invoices = [
                    SELECT Id, blng__Order__r.ShipToContact.FirstName,
                            blng__Order__r.ShipToContact.LastName, blng__Order__r.ShipToContact.Email,
                            blng__Order__r.ShippingStreet, blng__Order__r.ShippingCity,
                            blng__Order__r.ShippingState, blng__Order__r.ShippingPostalCode,
                            blng__Order__r.ShippingCountry,
                            blng__Order__r.BillToContact.FirstName, blng__Order__r.BillToContact.LastName,
                            blng__Order__r.BillToContact.Email,
                            blng__Order__r.BillingStreet,
                            blng__Order__r.BillingCity, blng__Order__r.BillingState,
                            blng__Order__r.BillingPostalCode, blng__Order__r.BillingCountry,
                           CurrencyIsoCode
                    FROM blng__Invoice__c
                    WHERE blng__LegalEntityReference__c IN :listOfInvoiceIds
            ];

        }
        return calculateTax(invoiceLines);*/
        List<blng__Invoice__c> invoices = [SELECT Id, Name FROM blng__Invoice__c WHERE Id IN :listOfInvoiceIds];
        return calculateTax(invoices);
    }

    public Map<Id, blng.TaxResults> postTax(List<String> listOfLegalEntityReferences) {
        System.debug('RemoteTaxInvoiceService.postTax() listOfLegalEntityReferences: ' + listOfLegalEntityReferences);
        List<blng__Invoice__c> invoices = [SELECT Id, Name FROM blng__Invoice__c WHERE Id IN :listOfLegalEntityReferences];
        return calculateTax(invoices);
    }

    public Map<Id, blng.TaxResults> cancelTax(List<String> listOfLegalEntityReferences) {
        System.debug('RemoteTaxInvoiceService.cancelTax() listOfLegalEntityReferences: ' + listOfLegalEntityReferences);
        List<blng__Invoice__c> invoices = [SELECT Id, Name FROM blng__Invoice__c WHERE Id IN :listOfLegalEntityReferences];
        return calculateTax(invoices);
    }

    public Map<Id, blng.TaxResults> calculateTax(List<blng__Invoice__c> invoices) {
        // Stubbed out
        Map<Id, blng.TaxResults> taxResultsByIds = new Map<Id, blng.TaxResults>();
        for(blng__Invoice__c invoice: invoices) {
            blng.TaxResults taxResults = new blng.TaxResults();
            taxResults.setIsSuccess(true);
            taxResults.setId(invoice.Id);
            taxResults.setTax(0.00);
            taxResultsByIds.put(invoice.Id, taxResults);
        }
        return taxResultsByIds;
    }

    /**
     * Interface to the database for the RemoteTaxInvoiceService class.
     */
    public interface RemoteTaxInvoiceServiceDatabaseInterface {

    }

    public class RemoteTaxInvoiceServiceDatabaseDefaultImpl implements RemoteTaxInvoiceServiceDatabaseInterface {

    }

}