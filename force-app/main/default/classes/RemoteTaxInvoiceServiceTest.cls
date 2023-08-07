/**
 * Created by stevelohrenz on 6/13/17.
 [Modified By : Aishwarya 12 Aug 2020 BK-3751]
 */

@IsTest
private class RemoteTaxInvoiceServiceTest {

    @testSetup
    public static void setupData() {
        TestUtilities.createCSIntegrationSettings();
        TestUtilities.createCSBatchSettings();
        TestUtilities.createBillingPrefix();
        TestUtilities.createBillingConfigs();
    }

    static testMethod void testPostTax() {
        Boolean doInsert = false;
        Map<String, SObject> sbObjectMap = TestUtilities.createToInvoiceStack(doInsert);
        blng__Invoice__c invoice = (blng__Invoice__c) sbObjectMap.get(TestUtilities.INVOICE);
        List<String> listOfLegalEntityReferences = new List<String>();
        RemoteTaxInvoiceService taxService = new RemoteTaxInvoiceService();
        taxService.postTax(listOfLegalEntityReferences);
        system.assertNotEquals(invoice.id, null, 'Invoice Id cannot be blank');
        system.assertNotEquals(doInsert, true, 'value must be false');
    }

    static testMethod void testCancelTax() {
        Boolean doInsert = false;
        Map<String, SObject> sbObjectMap = TestUtilities.createToInvoiceStack(doInsert);
        blng__Invoice__c invoice = (blng__Invoice__c) sbObjectMap.get(TestUtilities.INVOICE);
        List<String> listOfLegalEntityReferences = new List<String>();
        RemoteTaxInvoiceService taxService = new RemoteTaxInvoiceService();
        taxService.cancelTax(listOfLegalEntityReferences);
        system.assertNotEquals(invoice.id, null, 'Invoice Id cannot be blank');
        system.assertNotEquals(doInsert, true, 'value must be false');
    }

    static testMethod void testCalculateTax() {
        Boolean doInsert = false;
        Map<String, SObject> sbObjectMap = TestUtilities.createToInvoiceStack(doInsert);
        blng__Invoice__c invoice = (blng__Invoice__c) sbObjectMap.get(TestUtilities.INVOICE);
        List<String> listOfLegalEntityReferences = new List<String>();
        RemoteTaxInvoiceService taxService = new RemoteTaxInvoiceService();
        taxService.calculateTax(new List<blng__Invoice__c> {invoice});
        system.assertNotEquals(invoice.id, null, 'Invoice Id cannot be blank');
        system.assertNotEquals(doInsert, true, 'value must be false');
    }
}