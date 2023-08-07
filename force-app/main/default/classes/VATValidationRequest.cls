/**
* The object that outlines the structure of the request to the vat validation service.
* History: 
* 18/7/2018 : Modified by Kumar for Jira Ticket GGCW-2172
*/
public class VATValidationRequest {

    public VATValidationRequest(Account anAccount) {
        Systems aSystem = new Systems();
        aSystem.CallingApplication = 'SFDC-GE';
        DateTime today = DateTime.now();
        aSystem.MessageDate = today.format('yyyy-MM-dd');

        Header aHeader = new Header();
        aHeader.Systems = aSystem;       
        Header = aHeader;

        VATCodes vatCode = new VATCodes();
        //Modified By Kumar : GGCW-2172
        //vatCode.Country = anAccount.BillingCountry != null ? InvoiceUtilities.retrieveCountryCode(anAccount.BillingCountry) : '';
        vatCode.Country = anAccount.BillingCountryCode != null ? anAccount.BillingCountryCode : '';
        vatCode.VATNumber = anAccount.Tax_Id__c != null ? anAccount.Tax_Id__c : '';
        VATCodes = new List<VATCodes>();
        VATCodes.add(vatCode);
    }

    public class VATCodes {
        public String Country {get; set;}
        public String VATNumber {get; set;}
    }

    public Header Header {get; set;}
    public List<VATCodes> VATCodes {get; set;}

    public class Header {
        public Systems Systems {get; set;}
    }

    public class Systems {
        public String CallingApplication {get; set;}
        public String MessageDate {get; set;}
    }

    public String serializeToString(VATValidationRequest request) {
        return JSON.serialize(request);
    }
}