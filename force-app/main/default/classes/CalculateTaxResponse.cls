/**
 * Response holder class for the tax calculation api call
 *
 * Test class   : CalculateTaxResponseTest.cls
 * History:
 * 1. Modified By Kumar Gaurav on 1/6/2018 for Tax Rate updation on Order item coming from SAP response
*/

public with sharing class CalculateTaxResponse {
    public Header Header;
    public Content Content;
    public List<Message> Messages;

    public class Transaction_x {
        public MetaData MetaData;
        public List<CartItems> CartItems;
    }

    public class PersonName {
        public String Prefix;
        public String FirstNames;
        public String LastName;
    }
    
    public class TaxRates{
        public Integer TaxRate;
        public Integer TaxAmount;
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

    public class Customer {
        public String CustomerEmail;
    }

    public class CartItem {
        public Integer Quantity;
        public Integer Price;
        public Integer Tax;
        public String LineNumber;
        public String TAXCODE; //Added By Rajesh Kr - BK-6918
        public String TAXCOUNTRY; //Added By Rajesh Kr - BK-6918
        public List<TaxRates> TaxRates; // Added By Kumar GGCW-2478
        public ItemData ItemData;
    }

    public class Systems {
        public String CallingApplication;
        public String MessageDate;
        public String MessageStatus;
        public String MessageStatusText;
    }

    public class CartItems {
        public CartItem CartItem;
    }

    public class AddressGroup {
        public BillTo BillTo;
        public BillTo ShipTo;
    }

    public class Header {
        public Systems Systems;
    }

    public class MetaData {
        public Customer Customer;
        public AddressGroup AddressGroup;
        public String Currency_x;
        public String TaxLabel;
    }

    public class Content {
        public Transaction_x Transaction_x;
    }

    public class BillTo {
        public PersonName PersonName;
        public Address Address;
    }

    public class ItemData {
        public String ProductCode;
        public String ProductType;
    }

    public class Message {
        public String MessageReference;
        public String MessageSeverity;
        public String MessageType;
        public String MessageID;
        public String MessageText;
    }

    public static CalculateTaxResponse parse(String json) {
        String newJson = json.replace('Transaction', 'Transaction_x');
        newJson = newJson.replace('Currency', 'Currency_x');
        return (CalculateTaxResponse) System.JSON.deserialize(newJson, CalculateTaxResponse.class);
    }

    public static String serializeToString(CalculateTaxResponse request) {
        String returnString = JSON.serialize(request);
        returnString = returnString.replace('Transaction_x', 'Transaction');
        return returnString.replace('Currency_x', 'Currency');
    }

}