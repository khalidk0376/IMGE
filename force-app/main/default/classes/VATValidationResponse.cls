/**
     * The object that outlines the structure of the response from the vat validation service.
     */
public class VATValidationResponse {
    public Header Header {get; set;}
    public List<VATCodes> VATCodes = new List<VATCodes>();
    public List<Message> Messages = new List<Message>();
    
    
	public class VATCodes {
        public String Country {get; set;}
        public String VATNumber {get; set;}
        public String VATNumberUnformatted {get; set;}
        public String VATRegistrationType {get; set;}
        public Boolean ValidVAT {get; set;}
    }                    

    public class Header {
        public Systems Systems {get; set;}
    }

    public class Systems {
        public String CallingApplication {get; set;}
        public String MessageDate {get; set;}
        public String MessageStatus {get; set;}
        public String MessageStatusText {get; set;}
    }

    public class Message {
        public String MessageReference;
        public String MessageSeverity;
        public String MessageType;
        public String MessageID;
        public String MessageText;
    }
}