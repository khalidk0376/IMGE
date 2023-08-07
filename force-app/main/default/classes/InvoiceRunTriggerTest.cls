/**
 * Test class for the invoice run trigger.
 * * Modified By : Rajesh kumar Yadav Bk-3751
 */
@IsTest
private class InvoiceRunTriggerTest {

    @testSetup
    public static void setupData() {
        TestUtilities.createCSIntegrationSettings();
        TestUtilities.createCSBatchSettings();
        TestUtilities.createBillingPrefix();
        TestUtilities.createBillingConfigs();
    }

    static testMethod void testInvoiceRun() {

        Map<String, SObject> sbObjectMap = TestUtilities.createBillingBackgroundStack(true);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Product2 product = (Product2) sbObjectMap.get(TestUtilities.PRODUCT);
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);
        TestUtilities.closeWonOpportunity(opportunity.Id, true);

        //Order order = TestUtilities.createAutomatedOrderFromOpportunity(opportunity);

        blng__LegalEntity__c legalEntity = (blng__LegalEntity__c) sbObjectMap.get(TestUtilities.LEGAL_ENTITY);
        //List<OrderItem> orderItems = TestUtilities.queryOrderItemsByOrderId(order.Id);

        Contact contact = (Contact) sbObjectMap.get(TestUtilities.CONTACT);
        Map<Id, Contact> contactsByIds = new Map<Id, Contact>();
        Test.startTest();
        // Need to run the invoice scheduler after finished cancel & rebilling the invoices
        blng__InvoiceScheduler__c invoiceScheduler = new blng__InvoiceScheduler__c();
        invoiceScheduler.Name =  'InvoiceRunTriggerTest InvoiceScheduler ' + DateTime.now();
        invoiceScheduler.CurrencyIsoCode = 'USD';
        invoiceScheduler.blng__TargetDate__c = Date.today();
        invoiceScheduler.blng__Type__c = 'Once';
        invoiceScheduler.blng__StartDateTime__c = DateTime.now().addMinutes(1);

        insert invoiceScheduler;
        system.assertEquals(invoiceScheduler.CurrencyIsoCode, 'USD', 'Both values should be the same.');
        blng__InvoiceRun__c objinvoicerun = new blng__InvoiceRun__c ();
        objinvoicerun.Name = 'TestEUR invoice generation 2020-06-12 09:59:17';
        objinvoicerun.blng__TargetDate__c = Date.today();
        objinvoicerun.blng__UniqueId__c  = 'testEURa3B5500000075xQEAQ';
        objinvoicerun.blng__Status__c = 'Started';
        insert objinvoicerun;
        //objinvoicerun.blng__Status__c = 'Completed';
        update objinvoicerun;
        
        Test.stopTest();
    }

}