/**
 * Data holder for the invoice api rest call.
 */

public with sharing class InvoiceJournalResponse {
    public Header Header;
    public List<References> References;
    public List<Message> Messages;

    public class Item {
        public String ReferenceNumber;
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

    public class Message {
        public String MessageReference;
        public String MessageSeverity;
        public String MessageType;
        public String MessageID;
        public String MessageText;
    }

    public static InvoiceJournalResponse parse(String json) {
        return (InvoiceJournalResponse) System.JSON.deserialize(json, InvoiceJournalResponse.class);
    }

    /*public static String serializeToString(InvoiceJournalResponse request) {
        return JSON.serialize(request);
    } */

}