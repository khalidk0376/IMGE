/**
 * Test class for the RemoteTaxCalculationAPI class.
 Modification Log : [Modified By : Aishwarya 12 Aug 2020 BK-3751]
 */

@IsTest
private class RemoteTaxCalculationAPITest {

    @testSetup
    public static void setupData() {
        TestUtilities.createBillingPrefix();
        TestUtilities.createBillingConfigs();
        TestUtilities.createCSIntegrationSettings();
    }

    static testMethod void testCalculateTaxInvoicePostTax() {
        Boolean doInsert = false;
        Map<String, SObject> sbObjectMap = TestUtilities.createToInvoiceStack(doInsert);
        blng__Invoice__c invoice = (blng__Invoice__c) sbObjectMap.get(TestUtilities.INVOICE);

        blng.TaxParameters taxParameters = new blng.TaxParameters();
        taxParameters.setSObjectType(invoice.getSObjectType());
        taxParameters.setTaxMethod(RemoteTaxCalculationAPI.POST_TAX);
        taxParameters.listOfSObjectIds.add(invoice.Id);
        RemoteTaxCalculationAPI.calculateTax(taxParameters);
        system.assertNotEquals(invoice.id, null, 'Invoice Id cannot be blank');
    }

    static testMethod void testCalculateTaxInvoiceCancelTax() {
        Boolean doInsert = false;
        Map<String, SObject> sbObjectMap = TestUtilities.createToInvoiceStack(doInsert);
        blng__Invoice__c invoice = (blng__Invoice__c) sbObjectMap.get(TestUtilities.INVOICE);

        blng.TaxParameters taxParameters = new blng.TaxParameters();
        taxParameters.setSObjectType(invoice.getSObjectType());
        taxParameters.setTaxMethod(RemoteTaxCalculationAPI.CANCEL_TAX);
        taxParameters.listOfSObjectIds.add(invoice.Id);
        RemoteTaxCalculationAPI.calculateTax(taxParameters);
        system.assertNotEquals(invoice.id, null, 'Invoice Id cannot be blank');
    }

    static testMethod void testCalculateTaxInvoiceLineGetTax() {
        Boolean doInsert = false;
        Map<String, SObject> sbObjectMap = TestUtilities.createToInvoiceStack(doInsert);
        blng__InvoiceLine__c invoiceLine = (blng__InvoiceLine__c) sbObjectMap.get(TestUtilities.INVOICE_LINE);

        blng.TaxParameters taxParameters = new blng.TaxParameters();
        taxParameters.setSObjectType(invoiceLine.getSObjectType());
        taxParameters.setTaxMethod(null);
        taxParameters.setLegalEntityReferences(invoiceLine.Id);
        RemoteTaxCalculationAPI.calculateTax(taxParameters);
        system.assertNotEquals(invoiceLine.id, null, 'InvoiceLine Id cannot be blank');
    }

    static testMethod void testCalculateTaxOrderItemGetTax() {
        Boolean doInsert = false;
        Map<String, SObject> sbObjectMap = TestUtilities.createToInvoiceStack(doInsert);
        OrderItem orderItem = (OrderItem) sbObjectMap.get(TestUtilities.ORDER_ITEM);

        blng.TaxParameters taxParameters = new blng.TaxParameters();
        taxParameters.setSObjectType(orderItem.getSObjectType());
        taxParameters.setTaxMethod(null);
        taxParameters.setLegalEntityReferences(orderItem.Id);
        RemoteTaxCalculationAPI.calculateTax(taxParameters);
        system.assertNotEquals(orderItem.id, null, 'orderItem Id cannot be blank');
    }
}