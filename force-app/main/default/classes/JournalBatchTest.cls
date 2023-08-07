/**
* Project:             GAP
* Date:                Nov 10, 2017
* Created By:          Steve Lohrenz
* Test Class For:      JournalBatch.
* Code Coverage:       76%
* *************************************************************************
* @description Test class for JournalBatch
* *************************************************************************
* History:
*/

@IsTest
private class JournalBatchTest {
    private static TestUtilities utils = new TestUtilities();

    @testSetup
    public static void setupData() {
        TestUtilities.createCSIntegrationSettings();
        TestUtilities.createCSBatchSettings();
    }

    @isTest
    static void testExecuteJournalBatch() {

        System.debug('JournalBatchTest [' + okResponseString + ']');
        Map<String, SObject> sbObjectMap = TestUtilities.createToInvoiceStack(false);
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);
        Order order = (Order) sbObjectMap.get(TestUtilities.ORDER);
        OrderItem orderItem = (OrderItem) sbObjectMap.get(TestUtilities.ORDER_ITEM);

        List<OrderItem> orderItems = new List<OrderItem> {orderItem};

        blng__Invoice__c invoice = (blng__Invoice__c) sbObjectMap.get(TestUtilities.INVOICE);
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, okResponseString.replace('AAAAAAAAAAA', invoice.Id)));

        JournalBatchMockImpl mockImpl = new JournalBatchMockImpl();

        Test.startTest();
        JournalBatch journalBatch = new JournalBatch(false, 60, mockImpl);
        journalBatch.execute(null, new List<blng__Invoice__c> {invoice});
        //Database.executeBatch(journalBatch, 1000);
        journalBatch.finish(null);
        Test.stopTest();

        List<Error_Log__c> errorLogs = [SELECT Id FROM Error_Log__c];
        System.assertEquals(0, errorLogs.size(),'Size');
    }

    @isTest
    static void testExecuteJournalBatchError() {

        System.debug('JournalBatchTest [' + errorResponseString + ']');
        Map<String, SObject> sbObjectMap = TestUtilities.createToInvoiceStack(false);
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);
        Order order = (Order) sbObjectMap.get(TestUtilities.ORDER);
        OrderItem orderItem = (OrderItem) sbObjectMap.get(TestUtilities.ORDER_ITEM);

        List<OrderItem> orderItems = new List<OrderItem> {orderItem};

        blng__Invoice__c invoice = (blng__Invoice__c) sbObjectMap.get(TestUtilities.INVOICE);
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, errorResponseString.replace('AAAAAAAAAAA', invoice.Id)));

        JournalBatchMockImpl mockImpl = new JournalBatchMockImpl();

        Test.startTest();
        JournalBatch journalBatch = new JournalBatch(false, 60, mockImpl);
        journalBatch.execute(null, new List<blng__Invoice__c> {invoice});
        //Database.executeBatch(journalBatch, 1000);
        Test.stopTest();

        List<Error_Log__c> errorLogs = [SELECT Id FROM Error_Log__c];
        System.assertEquals(1, errorLogs.size(),'Size Error');
    }


    private static String okResponseString = '{' +
            '\"Header\": {' +
            '\"Systems\": {' +
            '\"CallingApplication\": \"SFDC\",' +
            '\"MessageDate\": \"2017-04-14\",' +
            '\"MessageStatus\": \"OK\",' +
            '\"MessageStatusText\": \"Data Posted\"' +
            '}' +
            '},' +
            '\"References\": [' +
            '{' +
            '\"Item\": {' +
            '\"ReferenceNumber\": \"AAAAAAAAAAA\"' +
            '}' +
            '}' +
            '],' +
            '\"Messages\": [{' +
            '\"MessageStatus\": \"OK\", ' +
            '\"MessageReference\": \"AAAAAAAAAAA\",' +
            '\"MessageType\": \"Test\", ' +
            '\"MessageText\": \"Testing Text\"' +
            '}]' +
            '}';

    private static String errorResponseString = '{' +
            '\"Header\": {' +
            '\"Systems\": {' +
            '\"CallingApplication\": \"SFDC\",' +
            '\"MessageDate\": \"2017-04-14\",' +
            '\"MessageStatus\": \"ERROR\",' +
            '\"MessageStatusText\": \"Data Posted\"' +
            '}' +
            '},' +
            '\"References\": [' +
            '{' +
            '\"Item\": {' +
            '\"ReferenceNumber\": \"AAAAAAAAAAA\"' +
            '}' +
            '}' +
            '],' +
            '\"Messages\": [{' +
            '\"MessageStatus\": \"ERROR\", ' +
            '\"MessageReference\": \"AAAAAAAAAAA\",' +
            '\"MessageType\": \"Test\", ' +
            '\"MessageText\": \"Testing Text\"' +
            '}]' +
            '}';
    /**
     * @description journal batch method
     */
    public class JournalBatchMockImpl implements JournalBatch.JournalBatchDataInterface {
        public void updateInvoices(List<blng__Invoice__c> updatedInvoices) {
            integer x = 0;
        }
    }
}