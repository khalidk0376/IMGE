/**
 * Interface for the factory for the remote services.
 */

public interface RemoteTaxService {

    Map<Id, blng.TaxResults> getTax(List<String> listOfIdentifiers);

    Map<Id, blng.TaxResults> postTax(List<String> listOfIdentifiers);

    Map<Id, blng.TaxResults> cancelTax(List<String> listofIdentifiers);

}