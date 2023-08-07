/**
 * Main integration class for integrating with the SF Bill Tax Integration Module.
 * After Rollback this class from UAT I will redeployed again this class with child user story.
 */

global class RemoteTaxCalculationAPI implements blng.TaxEngines {

    public static String POST_TAX = 'postTax';
    public static String CANCEL_TAX = 'cancelTax';
    public static String ORDER_ITEM_NAME = 'OrderItem';
    public static String INVOICE_LINE_NAME = 'blng__InvoiceLine__c';
    public static String INVOICE_NAME = 'blng__Invoice__c';

    /**
     * Integration point for the tax calculation. 
     */

    global static Map<Id, blng.TaxResults> calculateTax(blng.TaxParameters taxParameters) {
        System.debug('RemoteTaxCalculationAPI.calculateTax() entered method ' + taxParameters + ' getLegalEntityReferences ' + taxParameters.getLegalEntityReferences());
        RemoteTaxService service = getService(taxParameters.getSObjectType());
        Map<Id, blng.TaxResults> taxResultsByIds = new Map<Id, blng.TaxResults>();
        try {
            if (taxParameters.getTaxMethod() == POST_TAX) {
                taxResultsByIds = service.postTax(taxParameters.listOfSObjectIds);
            } else if (taxParameters.getTaxMethod() == CANCEL_TAX) {
                taxResultsByIds = service.cancelTax(taxParameters.listOfSObjectIds);
            } else {
                // When taxMethod doesn't match, it's GET_TAX.
                if (taxParameters.getLegalEntityReferences() != null) {
                    List<String> legalEntityStrings = taxParameters.getLegalEntityReferences().split(',');
                    taxResultsByIds = service.getTax(legalEntityStrings);
                } else {
                    System.debug(LoggingLevel.ERROR, 'RemoteTaxCalculationAPI.calculateTax getLegalEntityReferences is null. Please check the configuration of the products.');
                }
            }
        } catch (Exception eek) {
            System.debug(LoggingLevel.ERROR, 'RemoteTaxCalculationAPI.calculateTax() ' + eek.getMessage() + ' Stack ' + eek.getStackTraceString());
        }
        System.debug('RemoteTaxCalculationAPI.calculateTax() returning from method taxResultsByIds: ' + taxResultsByIds);
        return taxResultsByIds;
    }

    private static RemoteTaxService getService(SObjectType objectType) {
        if(objectType == Schema.getGlobalDescribe().get(ORDER_ITEM_NAME)) {
            return new RemoteTaxOrderProductService();
        } else if(objectType == Schema.getGlobalDescribe().get(INVOICE_LINE_NAME)) {
            return new RemoteTaxInvoiceLineService();
        } else if(objectType == Schema.getGlobalDescribe().get(INVOICE_NAME)) {
            return new RemoteTaxInvoiceService();
        } // Else condition is commented by Palla Kishore for the ticket BK-19604
       /* else {
            //to do
        } */
        return null;
    }

    // Scoped for future use by Salesforce - currently not used.
    global static void resetSObjectListofIds() {
        System.debug('RemoteTaxCalculationAPI.resetSObjectListofIds() entered method');
    }

    // Scoped for future use by Salesforce - currently not used.
    global static void resetLegalEntityReferences() {
        System.debug('RemoteTaxCalculationAPI.resetLegalEntityReferences()() entered method');
    }

}