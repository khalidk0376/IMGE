/**
 *@description test class for the data holder object CreateCustomerRequest.
 */

@IsTest
private class CreateCustomerRequestTest {
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
                '      \"TaxIndicator\": \"A\",'+
                '      \"TaxRegistration\": \"B\",'+
                '      \"TaxType\": \"C\",'+
                '      \"TaxJurisdiction\": \"D\",'+
                '      \"AggregatorCode\": \"E\",'+
                '      \"Title\": \"\",'+
                '      \"CompanyName1\": \"Informa\",'+
                '      \"CompanyName2\": \"\",'+
                '      \"CompanyName3\": \"\",'+
                '      \"LastName\": \"Informa\",'+
                '      \"FirstName\": \"MuleSoft\",'+
                '      \"FullName\": \"MuleSoft Informa\",'+
                '      \"ContactFunction\": \"Director\",'+
                '      \"Department\": \"Agile solutions team\",'+
                '      \"City\": \"London\",'+
                '      \"District\": \"SOHO\",'+
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
        CreateCustomerRequest obj = CreateCustomerRequest.parse(json);
        System.assertNotEquals(obj , null, 'condition should match');
        System.assertNotEquals(obj.Header.Systems , null, 'condition should match');
        System.assertEquals('SFDC', obj.Header.Systems.CallingApplication,'condition should match');
    }

    static testMethod void testCreateCustomerRequest() {
       /* Map<String, SObject> sbObjectMap = TestUtilities.createSBQQStack(false);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Contact contact = (Contact) sbObjectMap.get(TestUtilities.CONTACT);
        */
        Account account = new Account();
        account.Name = 'Test Account for the Ages';
        account.BillingCity = 'Oxnard';
        account.BillingCountry = 'USA';
        account.BillingPostalCode = '93030';
        account.BillingState = 'California';
        account.BillingStreet = '121 North G Street';
        account.ShippingCity = 'Los Angeles';
        account.ShippingCountry = 'USA';
        account.ShippingPostalCode = '90033';
        account.ShippingState = 'California';
        account.ShippingStreet = '1600 Pennsylvania Avenue';
        insert account;
        
        Contact obj = new Contact();
        obj.Email='testUtilEmail@testUtil.com';
        obj.FirstName = 'Test';
        obj.LastName = 'Contact';
        obj.MailingCity = 'Los Angeles';
        obj.MailingCountry = 'USA';
        obj.MailingPostalCode = '90033';
        obj.MailingState = 'California';
        obj.MailingStreet = '1600 Pennsylvania Avenue';
        obj.AccountId = account.Id;
        insert obj;
        System.assertNotEquals(obj, null,'condition should match');
      
        
        Test.StartTest();
        Account_Translated_FieldSet__c accountTrasaltedField = new Account_Translated_FieldSet__c ();
        accountTrasaltedField.account__c=account.Id;
        accountTrasaltedField.Translated_Account_Name__c = account.Name;
        accountTrasaltedField.Translated_Billing_Address_Line_1__c=account.BillingStreet;
        accountTrasaltedField.Translated_Billing_Address_Line_2__c=account.Billing_Address_Line_2__c;
        accountTrasaltedField.Translated_Billing_City__c=account.BillingCity;
        accountTrasaltedField.Translated_Billing_Country__c=account.BillingCountry;
        accountTrasaltedField.Translated_Billing_State_Province__c=account.BillingState;
        accountTrasaltedField.Translated_Billing_Zip_Postal_Code__c=account.BillingPostalCode;
        insert accountTrasaltedField;
        Test.StopTest();
        CreateCustomerRequest ccr = new CreateCustomerRequest(account, 'LE', obj);
        system.debug('ccr'+ccr);
        
    }
}