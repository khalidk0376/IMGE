/**
 * Test class for ValidateCustomerController
 */

@IsTest
private class ValidateCustomerControllerTest {
    @testSetup
    public static void setupData() {
        TestUtilities.createCSIntegrationSettings();
    }

    @isTest
    static void testValidateCustomerSuccess() {
        TestUtilities utils = new TestUtilities();

        Account account = TestUtilities.createAccount(false);
        account.Id = null;
        insert account;

        Contact contact = TestUtilities.createContact(false);
        contact.Id = null;
        contact.AccountId = account.Id;
        contact.Contact_Type__c = 'Invoice Contact';
        insert contact;

        Test.startTest();
        PageReference pageReference = Page.ValidateCustomer;
        Test.setCurrentPage(pageReference);
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, rESPONSESTRING));

        pageReference.getParameters().put('acctId', String.valueOf(account.Id));
        ApexPages.StandardController standardController = new ApexPages.StandardController(account);
        ValidateCustomerController controller = new ValidateCustomerController(standardController);

        PageReference forwardPage = controller.validateCustomer();

        account = [SELECT Id, Name, Address_Verified__c FROM Account WHERE Id = :account.Id limit 1];
        System.assert(account.Address_Verified__c,'Account address should be verified');
        Test.stopTest();
    }

    @isTest
    static void testValidateCustomerError() {
        TestUtilities utils = new TestUtilities();

        Account account = TestUtilities.createAccount(false);
        account.Id = null;
        insert account;

        Contact contact = TestUtilities.createContact(false);
        contact.Id = null;
        contact.AccountId = account.Id;
        contact.Contact_Type__c = 'Invoice Contact';
        insert contact;
        
        String iNTEGRATIONSERVICENAME = 'VALIDATE_CUSTOMER';
        Error_Log__c errlg = new Error_Log__c(Service_Source__c = 'Integration',Source_Name__c = iNTEGRATIONSERVICENAME);
        insert errlg;
        
        Test.startTest();
        PageReference pageReference = Page.ValidateCustomer;
        Test.setCurrentPage(pageReference);
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, rESPONSESTRINGERROR));

        pageReference.getParameters().put('acctId', String.valueOf(account.Id));
        ApexPages.StandardController standardController = new ApexPages.StandardController(account);
        ValidateCustomerController controller = new ValidateCustomerController(standardController);

        PageReference forwardPage = controller.validateCustomer();

        account = [SELECT Id, Name, Address_Verified__c FROM Account WHERE Id = :account.Id limit 1];
        System.assert(!account.Address_Verified__c,'');
        account.Address_Verified__c = true;
        update account;
        ValidateCustomerController obj = new ValidateCustomerController();
        Test.stopTest();
    }

    private static String rESPONSESTRING = '{'+
            '  \"Header\": {'+
            '    \"Systems\": {'+
            '      \"CallingApplication\": \"SFDC\",'+
            '      \"MessageDate\": \"2017-04-13\",'+
            '      \"MessageStatus\": \"OK\",'+
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
            '  }'+
            '}';

    private static String rESPONSESTRINGERROR = '{'+
            '  \"Header\": {'+
            '    \"Systems\": {'+
            '      \"CallingApplication\": \"SFDC\",'+
            '      \"MessageDate\": \"2017-04-13\",'+
            '      \"MessageStatus\": \"ERROR\",'+
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
            '  },\"Messages\": [{\"MessageReference\": \"test@informa.com\",\"MessageSeverity\": \"5\",\"MessageType\": \"Success\",\"MessageID\": \"0",\"MessageText\": \"Address Is Not Valid\"}]'+
            '}';

}