/**
 * Data handler for the invoice external api call.
 * Test Class : InvoiceJournalRequestTest
 * History:  Modified By Avinash for Jira Tickets BK-1771 on 27/06/2019
 */

public with sharing class InvoiceJournalRequest {
    public Header Header;
    public List<References> References;

    public InvoiceJournalRequest(List<blng__Invoice__c> invoices) {
        Systems aSystem = new Systems();
        aSystem.CallingApplication = 'SFDC-GE';
        DateTime today = DateTime.now();
        aSystem.MessageDate = today.format('yyyy-MM-dd');
        aSystem.MessageStatus = '';
        aSystem.MessageStatusText = '';

        this.Header = new Header();
        this.Header.Systems = aSystem;

        References = new List<References> ();
        for (blng__Invoice__c invoice : invoices) {
            References ref = new References();
            Item itm = new Item();
            itm.ReferenceNumber = invoice.Id;
            //Modified by Avinash : BK-1771
            if (!invoice.Invoice_Submitted_Processing__c) {
                itm.Status = 'Posted';
            } else {
                itm.Status = 'Cancelled';
            }
            ref.Item = itm;

            References.add(ref);
        }
    }

    public class Item {
        public String ReferenceNumber;
        public String Status;
    }

    public class Header {
        public Systems Systems;
    }

    public class References {
        public Item Item;
    }

    public class Systems {
        public String CallingApplication;
        public String MessageDate;
        public String MessageStatus;
        public String MessageStatusText;
    }


    public static InvoiceJournalRequest parse(String json) {
        return (InvoiceJournalRequest) System.JSON.deserialize(json, InvoiceJournalRequest.class);
    }

    public static String serializeToString(InvoiceJournalRequest request) {
        return JSON.serialize(request);
    }

}