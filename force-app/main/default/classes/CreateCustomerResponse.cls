/**
 * Data holder for the create customer api call. 
 */

public with sharing class CreateCustomerResponse {
    public Header Header;
    public CustomerInterface CustomerInterface;
    public Results Results;
    public List<Message> Messages;

    public class Item {
        public String PartnerRole;
        public String CustomerNumber;
        public String ExternalReference;
        public String SalesOrg;
        public String BusinessPartnerType;
        public String Division;
        public String DistributionChannel;
        public String Title;
        public String CompanyName1;
        public String CompanyName2;
        public String CompanyName3;
        public String LastName;
        public String FirstName;
        public String FullName;
        public String Department;
        public String City;
        public String PostalCode;
        public String AddressLine1;
        public String AddressLine2;
        public String Country;
        public String State;
        public String PhoneNumber;
        public String FaxNumber;
        public String EmailAddress;
    }

    public class CustomerInterface {
        public Item Item;
    }

    public class Results {
        public String BusinessPartnerNumber;
        public String BusinessPartnerRole;
        public String BusinessPartnerExternalReference;
        public String ContactPerson; 
    }

    public class Header {
        public Systems Systems;
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

    public static CreateCustomerResponse parse(String json) {
        //String newJson = json.replace('System', 'System_x');
        return (CreateCustomerResponse) System.JSON.deserialize(json, CreateCustomerResponse.class);
    }

    /*public static String serializeToString(CreateCustomerResponse request) {
        String returnString = JSON.serialize(request);
        return returnString.replace('System_x', 'System');
    } */

}