/**
 * Created by stevelohrenz on 5/4/17.
  [Modified By : Aishwarya 12 Aug 2020 BK-3751]
 */

@IsTest
public class ValidateCustomerRequestTest {

    static testMethod void testParse() {
        String json = '{'+
                '\"Header\": { \"Systems\": {'+
                '\"CallingApplication\": \"SFDC-GE\", \"MessageDate\": \"2017-05-04\", \"MessageStatus\": \"10\", \"MessageStatusText\": \"Tax Calculation\"'+
                '} },'+
                '\"Content\": { \"AddressWrapper\": {'+
                '\"Customer\": {'+
                '\"CustomerNumber\": \"BP010101010101\", \"CustomerNumberType\": \"BP\", \"CustomerGroup\": \"Group\", \"CustomerEmail\": \"mulesoft@informa.com\"'+
                '}, \"Person\": {'+
                '\"Prefix\": \"Mr.\",'+
                '\"FirstNames\": \"Peter Charley\", \"LastName\": \"Mc Afee\"'+
                '}, \"Address\": {'+
                '\"Organisation\": \"Informa\", \"Department\": \"Global Support\", \"AddressLine1\": \"Schimmelt 32\", \"AddressLine2\": \"\",'+
                '\"City\": \"Eindhoven\",'+
                '\"State\": \"\",'+
                '\"PostalCode\": \"5611 ZX\", \"Country\": \"NL\",'+
                '\"PhoneNumber\": \"3161234567890\", \"PhoneExtension\": \"x1234\", \"FaxNumber\": \"3161234567899\"'+
                '} }'+
                '} }';
        ValidateCustomerRequest obj = ValidateCustomerRequest.parse(json);
        System.assert(obj!= null ,'condition should match');
    }

    static testMethod void testValidateCustomerRequest() {
        Map<String, SObject> sbObjectMap = TestUtilities.createSBQQStack(false);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        system.assertNotEquals(account,null, 'account should not be blank');
        Contact contact = (Contact) sbObjectMap.get(TestUtilities.CONTACT);
        System.assert(contact != null,'Condition Match');
        ValidateCustomerRequest ccr = new ValidateCustomerRequest(account, contact);
    }
}