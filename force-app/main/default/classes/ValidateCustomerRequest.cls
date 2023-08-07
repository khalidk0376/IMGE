/**
 * Request object for the validate customer api outside call.
 * History :
 * 18/7/2018 : Modified by Kumar for Jira Ticket GGCW-2172
 */

public with sharing class ValidateCustomerRequest {

    public ValidateCustomerRequest(Account account, Contact primaryContact) {
        Systems aSystem = new Systems();
        aSystem.CallingApplication = 'SFDC-GE';
        DateTime today = DateTime.now();
        aSystem.MessageDate = today.format('yyyy-MM-dd');
        aSystem.MessageStatus = '';
        aSystem.MessageStatusText = '';
        aSystem.SystemReference = account.Id;

        this.Header = new Header();
        this.Header.Systems = aSystem;

        AddressWrapper anAddressWrapper = new AddressWrapper();
        Customer aCustomer = new Customer();
        aCustomer.CustomerEmail = primaryContact.Email != null ? primaryContact.Email : '';
        aCustomer.CustomerGroup = '';
        aCustomer.CustomerNumber = '';
        aCustomer.CustomerNumberType = 'web';

        Person aPerson = new Person();
        aPerson.FirstNames = primaryContact.FirstName != null ? primaryContact.FirstName : ' UNK';
        aPerson.LastName = primaryContact.LastName != null ? primaryContact.LastName : 'UNK';

        Address anAddress = new Address();
        anAddress.Organisation = '';
        anAddress.Department = '';
        Map<Integer, String> billMailingAddress = InvoiceUtilities.splitAddress(account.BillingStreet);
        anAddress.AddressLine1 = billMailingAddress.get(1);
        anAddress.AddressLine2 = billMailingAddress.get(2);
        anAddress.City = account.BillingCity != null ? account.BillingCity : '';
        //Modified By Kumar : GGCW-2172
        //anAddress.State = InvoiceUtilities.retrieveStateCode(account.BillingState);
        //anAddress.Country = InvoiceUtilities.retrieveCountryCode(account.BillingCountry);
        anAddress.State = account.BillingStateCode;
        anAddress.Country = account.BillingCountryCode;
        anAddress.PostalCode = account.BillingPostalCode != null ? account.BillingPostalCode : '';
        anAddress.PhoneNumber = primaryContact.Phone != null ? primaryContact.Phone : '';
        anAddress.PhoneExtension = '';
        anAddress.FaxNumber = primaryContact.Fax != null ? primaryContact.Fax : '';
        anAddressWrapper.Customer = aCustomer;
        anAddressWrapper.Person = aPerson;
        anAddressWrapper.Address = anAddress;

        this.Content = new Content();
        this.Content.AddressWrapper = anAddressWrapper;

    }

    public Header Header;
    public Content Content;

    public class Header {
        public Systems Systems;
        public List<DataPacket> DataPacket = new List<DataPacket>();
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
        public String SystemReference;
    }

    public class DataPacket {
        public String DataField;
        public String DataValue;
    }


    public static ValidateCustomerRequest parse(String json) {
        return (ValidateCustomerRequest) System.JSON.deserialize(json, ValidateCustomerRequest.class);
    }

    public static String serializeToString(ValidateCustomerRequest request) {
        return JSON.serialize(request);
    }
}