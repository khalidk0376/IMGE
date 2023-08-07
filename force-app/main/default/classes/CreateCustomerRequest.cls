/**
 * Data holder for the create customer api call.
 * History :
 * 18/7/2018 : Modified by Kumar for Jira Ticket GGCW-2172
 * Update : GGCW-2734 --Changes in Address Validation/Create Customer Call to accommodate the new fields of Arabic Address Lines
 */

public with sharing class CreateCustomerRequest {
    public Header Header;
    //public MetaData MetaData;
    public CustomerInterface CustomerInterface;
    public transient Account_Translated_FieldSet__c accountTranslatedFieldSet;
    public CreateCustomerRequest(Account account, String legalEntityCode, Contact primaryContact) {
        Systems aSystem = new Systems();
        aSystem.CallingApplication = 'SFDC-GE';
        DateTime today = DateTime.now();
        aSystem.MessageDate = today.format('yyyy-MM-dd');
        aSystem.MessageStatus = '';
        aSystem.MessageStatusText = '';
        aSystem.SystemReference = account.Id;

        this.Header = new Header();
        this.Header.Systems = aSystem;

        Item anItem = new Item();
        //anItem.PartnerRole = account.PartnerRole;
        anItem.PartnerRole = 'SP';
        anItem.CustomerNumber = '';
        anItem.ExternalReference = account.Id;
        anItem.SalesOrg = legalEntityCode;
        anItem.BusinessPartnerType = 'Company';
        anItem.TaxIndicator = '';
        anItem.TaxRegistration = account.Tax_Id__c;
        anItem.TaxType = '';
        anItem.TaxJurisdiction = '';
        anItem.AggregatorCode = '';
        //anItem.Title = primaryContact.Title != null ? primaryContact.Title : '';
        anItem.Title = '';
        anItem.CompanyName1 = account.Name != null ? account.Name : '';
        anItem.CompanyName2 = '';
        anItem.CompanyName3 = '';
        anItem.FirstName = primaryContact.FirstName != null ? primaryContact.FirstName : 'UNK';
        anItem.LastName = primaryContact.LastName != null ? primaryContact.LastName : 'UNK';
        anItem.FullName = primaryContact.Name != null ? primaryContact.Name : ' UNK';
        anItem.ContactFunction = '';
        anItem.Department = '';
        anItem.District = '';
        Map<Integer, String> mailingAddress = InvoiceUtilities.splitAddress(primaryContact.Account.BillingStreet);
        anItem.AddressLine1 = mailingAddress.get(1);
        anItem.AddressLine2 = mailingAddress.get(2);
        anItem.City = primaryContact.Account.BillingCity != null ? primaryContact.Account.BillingCity : '';
        anItem.PostalCode = primaryContact.Account.BillingPostalCode != null ? primaryContact.Account.BillingPostalCode : '';
        //Modified By Kumar : GGCW-2172
        //anItem.State = InvoiceUtilities.retrieveStateCode(primaryContact.Account.BillingState);
        //anItem.Country = InvoiceUtilities.retrieveCountryCode(primaryContact.Account.BillingCountry);
        anItem.State = primaryContact.Account.BillingStateCode;
        anItem.Country = primaryContact.Account.BillingCountryCode;
        
        anItem.PhoneNumber = primaryContact.Phone != null ? primaryContact.Phone : '';
        anItem.FaxNumber = primaryContact.Fax != null ? primaryContact.Fax : '';
        anItem.EmailAddress = primaryContact.Email != null ? primaryContact.Email : '';
        
        //Added by AQ to update translated additional account information.
        
        Account acct=[SELECT Id,Name,(SELECT Translated_Account_Name__c,Translated_Billing_Address_Line_1__c,Translated_Billing_Address_Line_2__c,Translated_Billing_City__c,Translated_Billing_Country__c,Translated_Billing_State_Province__c,Translated_Billing_Zip_Postal_Code__c,Address_Version__c from Account_Translated_FieldSets__r) from account where id=:account.Id limit 1 ];
        
        if(acct.Account_Translated_FieldSets__r!=null && acct.Account_Translated_FieldSets__r.size() > 0)
             accountTranslatedFieldSet=acct.Account_Translated_FieldSets__r[0];
        if(accountTranslatedFieldSet!=null){
            anItem.InternationalAddresses=new List<InternationalAddress>();
            InternationalAddress intlAddress = new InternationalAddress();
            intlAddress.CompanyName1 = accountTranslatedFieldSet.Translated_Account_Name__c;
            intlAddress.AddressLine1 = accountTranslatedFieldSet.Translated_Billing_Address_Line_1__c;
            intlAddress.AddressLine2 = accountTranslatedFieldSet.Translated_Billing_Address_Line_2__c;
            intlAddress.City = accountTranslatedFieldSet.Translated_Billing_City__c;
            intlAddress.PostalCode = accountTranslatedFieldSet.Translated_Billing_Zip_Postal_Code__c;
            intlAddress.AddressVersion = accountTranslatedFieldSet.Address_Version__c;
        
            anItem.InternationalAddresses.add(intlAddress);
        }
        
        this.CustomerInterface = new CustomerInterface();
        this.CustomerInterface.Item = anItem;
    }
    
    public class Item {
        public String PartnerRole;
        public String CustomerNumber;
        public String ExternalReference;
        public String SalesOrg;
        public String BusinessPartnerType;
        public String TaxIndicator;
        public String TaxRegistration;
        public String TaxType;
        public String TaxJurisdiction;
        public String AggregatorCode;
        public String Title;
        public String CompanyName1;
        public String CompanyName2;
        public String CompanyName3;
        public String LastName;
        public String FirstName;
        public String FullName;
        public String ContactFunction;
        public String Department;
        public String City;
        public String District;
        public String PostalCode;
        public String AddressLine1;
        public String AddressLine2;
        public String Country;
        public String State;
        public String PhoneNumber;
        public String FaxNumber;
        public String EmailAddress;
        public List<InternationalAddress> InternationalAddresses;
    }
    //Additional Item is the translated information of Acount Address and related info.
    public class InternationalAddress {
        public String AddressVersion;
        public String Title;
        public String CompanyName1;      
        public String CompanyName2;
        public String LastName;
        public String FirstName;
        public String FullName;
        public String SearchName1;
        public String SearchName2;
         public String AddressLine1;     
        public String AddressLine2;      
        public String No;
        public String NumberSupplement;
        public String Department;
        public String City;               
        public String District;
        public String PostalCode;
        public String Language;           
       
    }

    public class CustomerInterface {
        public Item Item;
        
    }

    public class Header {
        public Systems Systems;
    }

    public class Systems {
        public String CallingApplication;
        public String MessageDate;
        public String MessageStatus;
        public String MessageStatusText;
        public String SystemReference;
    }

    public static CreateCustomerRequest parse(String json) {
        //String newJson = json.replace('System', 'System_x');
        return (CreateCustomerRequest) System.JSON.deserialize(json, CreateCustomerRequest.class);
    }

    public static String serializeToString(CreateCustomerRequest request) {
        return JSON.serialize(request);
        //return returnString.replace('System_x', 'System');
    }

}