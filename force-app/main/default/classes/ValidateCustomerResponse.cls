/**
 * Created by stevelohrenz on 5/4/17.
 */

public with sharing class ValidateCustomerResponse {

    public Header Header;
    public Content Content;
    public List<Message> Messages;

    public class Header {
        public Systems Systems;
        public List<DataPacket> DataPacket;
    }

    public class Address {
        public String Organisation;
        public String Department;
        public String AddressLine1;
        public String AddressLine2;
        public String City;
        public String State;
        public String PostalCode;
        public String Country;
        public String PhoneNumber;
        public String PhoneExtension;
        public String FaxNumber;
    }

    public class AddressWrapper {
        public Customer Customer;
        public Person Person;
        public Address Address;
    }

    public class Customer {
        public String CustomerNumber;
        public String CustomerNumberType;
        public String CustomerGroup;
        public String CustomerEmail;
    }

    public class Content {
        public AddressWrapper AddressWrapper;
    }

    public class Person {
        public String FirstNames;
        public String LastName;
    }

    public class Systems {
        public String CallingApplication;
        public String MessageDate;
        public String MessageStatus;
        public String MessageStatusText;
    }

    public class DataPacket {
        public String DataField;
        public String DataValue;
    }

    public class Message {
        public String MessageReference;
        public String MessageSeverity;
        public String MessageType;
        public String MessageID;
        public String MessageText;
    }


    public static ValidateCustomerResponse parse(String json) {
        return (ValidateCustomerResponse) System.JSON.deserialize(json, ValidateCustomerResponse.class);
    }
}