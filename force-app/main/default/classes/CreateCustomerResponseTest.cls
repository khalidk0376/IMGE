/**
 * Test class for the data holder object CreateCustomerRespnose.
 */

@IsTest
private class CreateCustomerResponseTest {
    static testMethod void testParse() {
        String json = '{'+
                '  \"Header\": {'+
                '    \"Systems\": {'+
                '      \"CallingApplication\": \"SFDC\",'+
                '      \"MessageDate\": \"2017-04-13\",'+
                '      \"MessageStatus\": \"0\",'+
                '      \"MessageStatusText\": \"\"'+
                '    }'+
                '  },'+
                '  \"CustomerInterface\": {'+
                '    \"Item\": {'+
                '      \"PartnerRole\": \"SP\",'+
                '      \"CustomerNumber\": \"\",'+
                '      \"ExternalReference\": \"SFDC123456\",'+
                '      \"SalesOrg\": \"IN02\",'+
                '      \"BusinessPartnerType\": \"2\",'+
                '      \"Division\": \"IO\",'+
                '      \"DistributionChannel\": \"IN\",'+
                '      \"Title\": \"\",'+
                '      \"CompanyName1\": \"Informa\",'+
                '      \"CompanyName2\": \"\",'+
                '      \"CompanyName3\": \"\",'+
                '      \"LastName\": \"Informa\",'+
                '      \"FirstName\": \"MuleSoft\",'+
                '      \"FullName\": \"MuleSoft Informa\",'+
                '      \"Department\": \"Agile solutions team\",'+
                '      \"City\": \"London\",'+
                '      \"PostalCode\": \"CM23 2ZZ\",'+
                '      \"AddressLine1\": \"1Z, Dane Street\",'+
                '      \"AddressLine2\": \"\",'+
                '      \"Country\": \"UK\",'+
                '      \"State\": \"HT\",'+
                '      \"PhoneNumber\": \"+44 1279 123456\",'+
                '      \"FaxNumber\": \"+44 1279 234567\",'+
                '      \"EmailAddress\": \"mulesoft@informa.com\"'+
                '    }'+
                '  },'+
                '  \"Results\": {'+
                '    \"BusinessPartnerNumber\": \"0001010327\"'+
                '  }'+
                '}';
        CreateCustomerResponse obj = CreateCustomerResponse.parse(json);
        System.assertNotEquals(obj , null,'condition should match');
        System.assertNotEquals(obj.Header.Systems , null,'condition should match');
        System.assertEquals('SFDC', obj.Header.Systems.CallingApplication,'condition should match');
    }
}