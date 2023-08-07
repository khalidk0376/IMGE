/**
 * Test class for the InvoiceJournalResponse
 */

@IsTest
private class InvoiceJournalResponseTest {
    static testMethod void testParse() {
        String json = '{'+
                '\"Header\": {'+
                '\"Systems\": {'+
                '\"CallingApplication\": \"SFDC\",'+
                '\"MessageDate\": \"2017-04-14\",'+
                '\"MessageStatus\": \"0\",'+
                '\"MessageStatusText\": \"Data Posted\"'+
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
        InvoiceJournalResponse obj = InvoiceJournalResponse.parse(json);
        System.assert(obj != null,'condition should match');
    }
}