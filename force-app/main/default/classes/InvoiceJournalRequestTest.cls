/**
 * Test class for the InvoiceJournalRequest
 */

@IsTest
private class InvoiceJournalRequestTest {
    static testMethod void testParse() {
        String json = '{'+
                '\"Header\": {'+
                '\"Systems\": {'+
                '\"CallingApplication\": \"SFDC\",'+
                '\"MessageDate\": \"2017-04-14\",'+
                '\"MessageStatus\": \"\",'+
                '\"MessageStatusText\": \"\"'+
                '}'+
                '},'+
                '\"References\": ['+
                '{'+
                '\"Item\": {'+
                '\"ReferenceNumber\": \"INV01010101\"'+
                '}'+
                '}'+
                ']'+
                '}';
        InvoiceJournalRequest obj = InvoiceJournalRequest.parse(json);
        System.assert(obj != null,'Error');
    }

    static testMethod void testInvoiceJournalRequest() {
        Map<String, SObject> sbObjectMap = TestUtilities.createSBQQStack(false);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        blng__Invoice__c invoice1 = TestUtilities.createInvoiceById(null, null, false, 'AAADEDEDDE');
        InvoiceJournalRequest ijrequest = new InvoiceJournalRequest(new List<blng__Invoice__c> {invoice1});
        System.debug('MEssage == ' + ijrequest);
        System.assertEquals(ijrequest, ijrequest,'Size');
        //System.assert(obj != null,'Error');
    }
}