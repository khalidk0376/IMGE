/**
* Created by stevelohrenz on 5/25/17.
*/

@IsTest
private class CreateCustomerControllerTest {
    
    @testSetup
    public static void setupData() {
        TestUtilities.createCSIntegrationSettings();
        TestUtilities.createCSBatchSettings();
        TestUtilities.createBillingPrefix();
        TestUtilities.createBillingConfigs();
    }
    
    @isTest
    static void testCreateCustomer() {
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
        
        blng__LegalEntity__c legalentity1 = new blng__LegalEntity__c(Name = 'Test LegalEntity' , blng__Active__c = true , Legal_Entity_Code__c = 'AE006');
        insert legalentity1;
        
        Account_Legal_Entity__c acntE = new Account_Legal_Entity__c();
        acntE.Account__c = account.id;
        acntE.Legal_Entity__c = legalentity1.Id;
        insert acntE;
        
    	//   List<Account_Legal_Entity__c> accountLegalEntities = new List<Account_Legal_Entity__c>();
     	//   accountLegalEntities.add(acntE);
        
        System.assertNotEquals(account.Name, null , 'Account cannot be null');
        Contact oCon = new Contact(LastName='ContTest1', Email='test1contact@duptest.com', AccountId = account.Id, MailingStreet = 'Test',MailingCity ='Test',MailingState='',MailingCountry='India');
        insert oCon;
        
        Brand__c oBrand = new Brand__c(Name='World of Concrete', SSC_Email_Distribution_ID__c = 'test@test.tst');
        insert oBrand;
        
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Brand__c=oBrand.id , Event_Edition_Pool__c = 'WOC');
        insert oEventseries;
        
        Event_Edition__c edi = new Event_Edition__c ();
        edi.name = 'Arab Health 2017';
        edi.Approval_Service_Now_ID__c = '123';
        edi.Alternate_Currency__c = 'AED';
        edi.CurrencyIsoCode='USD';
        edi.Tab1__c='Test';
        edi.Tab7__c = 'test1';
        edi.Event_Edition_Status__c = 'Completed';
        edi.End_Date__c = date.today().adddays(5);
        edi.Event_Website__c = 'https://www.google.com';
        edi.Event_Edition_Image_URL__c = 'test';
        edi.Invoice_From_Email_ID__c = 'test';
        edi.Max_Hold_Booth__c = 3;
        edi.Max_Hold_Days__c = 2;
        edi.Measurement__c = 'Meters';
        edi.Next_Edition__c = '2016';
        edi.Payment_Schedule__c = '50-50';
        edi.Start_Date__c = date.today();
        edi.Venue__c = 'Test';
        edi.Year__c = '2020';
        edi.Event_Code__c  = 'sbwoc7';
        edi.Cutoff_Date_1__c = date.today().adddays(1);
        edi.Part_of_Series__c = oEventseries.Id;
        insert edi;
        
        Contract contracts=new Contract();
        contracts.StartDate=Date.today();
        contracts.AccountId=account.Id;
        contracts.Status='Draft';
        contracts.StartDate = Date.today();
        Insert contracts;
        
        Opportunity opp=new opportunity(Name='TestOpp');
        opp.AccountId=account.Id;
        opp.CloseDate = Date.newInstance(2019, 10, 03);
        opp.StageName = 'Proposal sent';
        opp.EventEdition__c= edi.Id;
        //opp.SBQQ__AmendedContract__c='8001F0000000uavQAA';
        opp.Main_Contract__c=contracts.Id;
        opp.Billing_Contact__c=oCon.Id;
        Insert opp;
        
       
        order ord = new order( Status='draft');
        ord.EffectiveDate=Date.newInstance(2019, 10, 01);
        ord.AccountId=account.Id;
        ord.OpportunityId=opp.Id;
        ord.BillToContactId=opp.Billing_Contact__c;
        Insert ord;
       
        Boolean doInsert = false;
        Map<String, SObject> sbObjectMap = TestUtilities.createToOrderStack(doInsert);
        //Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Contact contact = (Contact) sbObjectMap.get(TestUtilities.CONTACT);
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);
        blng__LegalEntity__c legalEntity = (blng__LegalEntity__c) sbObjectMap.get(TestUtilities.LEGAL_ENTITY);
        Order anOrder = (Order) sbObjectMap.get(TestUtilities.ORDER);
        OrderItem anOrderItem = (OrderItem) sbObjectMap.get(TestUtilities.ORDER_ITEM);
        anOrderItem.blng__LegalEntity__c = legalEntity.Id;
        anOrderItem.blng__LegalEntity__r = legalEntity;
        
        CreateCustomerControllerDatabaseMockImpl databaseMockImpl = new CreateCustomerControllerDatabaseMockImpl();
        databaseMockImpl.returnOrder = anOrder;
        databaseMockImpl.returnOrderItems.add(anOrderItem);
        databaseMockImpl.returnAccount = account;
        databaseMockImpl.returnBillingContacts.put(anOrder.Id, contact);
        
        CreateCustomerController.CreateCustomerControllerDatabaseDefaultImpl obj  = new CreateCustomerController.CreateCustomerControllerDatabaseDefaultImpl();
        // obj.queryOrderByOrderId(anOrder.id);
      	// obj.insertAccountLegalEntities(accountLegalEntities);
        PageReference pageReference = Page.CreateCustomer;
        Test.setCurrentPage(pageReference);
        Account_Translated_FieldSet__c acc_ReqTrasaltedField = new Account_Translated_FieldSet__c ();
        acc_ReqTrasaltedField.account__c=account.Id;
        acc_ReqTrasaltedField.Translated_Account_Name__c = account.Name;
        acc_ReqTrasaltedField.Translated_Billing_Address_Line_1__c=account.BillingStreet;
        acc_ReqTrasaltedField.Translated_Billing_Address_Line_2__c=account.Billing_Address_Line_2__c;
        acc_ReqTrasaltedField.Translated_Billing_City__c=account.BillingCity;
        acc_ReqTrasaltedField.Translated_Billing_Country__c=account.BillingCountry;
        acc_ReqTrasaltedField.Translated_Billing_State_Province__c=account.BillingState;
        acc_ReqTrasaltedField.Translated_Billing_Zip_Postal_Code__c=account.BillingPostalCode;
        insert acc_ReqTrasaltedField;
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, RESPONSE_STRING));
        pageReference.getParameters().put('ordId', String.valueOf(anOrder.Id));
        ApexPages.StandardController standardController = new ApexPages.StandardController(anOrder);
        CreateCustomerController controller = new CreateCustomerController(standardController, databaseMockImpl);
        
        CreateCustomerController controller2 = new CreateCustomerController(databaseMockImpl);
        CreateCustomerController controller3 = new CreateCustomerController();
        ApexPages.StandardController sc = new ApexPages.StandardController(anOrder);
        CreateCustomerController controller4 = new CreateCustomerController(sc);
        controller3.createCustomerCallout(ord.Id);
        Test.startTest();
        try {
            
            PageReference forwardPage = controller.createCustomer();
            System.assertNotEquals(forwardPage.getUrl(), null , 'URL must not be blank or null in order to create customer.');
        } catch (Exception eek) {
            System.debug('Error Message : ' + eek.getMessage() + 'At line number' + eek.getLineNumber() + 'Cause of Exception' + eek.getCause());
        }
        
        Test.stopTest();
        
        // System.assertNotEquals(null, databaseMockImpl.insertedAccountLegalEntities);
        // System.assertEquals(1, databaseMockImpl.insertedAccountLegalEntities.size());
        // System.assertEquals('Success', databaseMockImpl.updatedOrder.Create_Customer_Result__c);
    }
    
    @isTest
    static void testCreateCustomerError() {
        Boolean doInsert = false;
        Map<String, SObject> sbObjectMap = TestUtilities.createToOrderStack(doInsert);
       	Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Contact contact = (Contact) sbObjectMap.get(TestUtilities.CONTACT);
       
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);
        blng__LegalEntity__c legalEntity = (blng__LegalEntity__c) sbObjectMap.get(TestUtilities.LEGAL_ENTITY);
        Order anOrder = (Order) sbObjectMap.get(TestUtilities.ORDER);
        OrderItem anOrderItem = (OrderItem) sbObjectMap.get(TestUtilities.ORDER_ITEM);
        anOrderItem.blng__LegalEntity__c = legalEntity.Id;
        anOrderItem.blng__LegalEntity__r = legalEntity;
        
        CreateCustomerControllerDatabaseMockImpl databaseMockImpl = new CreateCustomerControllerDatabaseMockImpl();
        databaseMockImpl.returnOrder = anOrder;
        databaseMockImpl.returnOrderItems.add(anOrderItem);
        databaseMockImpl.returnAccount = account;
        databaseMockImpl.returnBillingContacts.put(anOrder.Id, contact);
        
        PageReference pageReference = Page.CreateCustomer;
        Test.setCurrentPage(pageReference);
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, RESPONSE_STRING_ERROR));
        pageReference.getParameters().put('ordId', String.valueOf(anOrder.Id));
        ApexPages.StandardController standardController = new ApexPages.StandardController(anOrder);
        CreateCustomerController controller = new CreateCustomerController(standardController, databaseMockImpl);
        
        Test.startTest();
        try {
          
            PageReference forwardPage = controller.createCustomer();
            System.assertNotEquals(forwardPage.getUrl(), null , 'URL must not be blank or null in order to create customer.');
        } catch (Exception eek) {
            System.debug('Error Message : ' + eek.getMessage() + 'At line number' + eek.getLineNumber() + 'Cause of Exception' + eek.getCause());
        }
        
        Test.stopTest();
        
        System.assertEquals(null, databaseMockImpl.insertedAccountLegalEntities, 'Account Legal Entity must not be null');
        // System.assertEquals(1, databaseMockImpl.insertedAccountLegalEntities.size());
        // System.assertEquals('Success', databaseMockImpl.updatedOrder.Create_Customer_Result__c);
    }
    
    @isTest
    static void testCreateCustomerError2() {
        Boolean doInsert = false;
        Map<String, SObject> sbObjectMap = TestUtilities.createToOrderStack(doInsert);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Contact contact = (Contact) sbObjectMap.get(TestUtilities.CONTACT);
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);
        blng__LegalEntity__c legalEntity = (blng__LegalEntity__c) sbObjectMap.get(TestUtilities.LEGAL_ENTITY);
        Order anOrder = (Order) sbObjectMap.get(TestUtilities.ORDER);
        OrderItem anOrderItem = (OrderItem) sbObjectMap.get(TestUtilities.ORDER_ITEM);
        anOrderItem.blng__LegalEntity__c = legalEntity.Id;
        anOrderItem.blng__LegalEntity__r = legalEntity;
        
        CreateCustomerControllerDatabaseMockImpl databaseMockImpl = new CreateCustomerControllerDatabaseMockImpl();
        databaseMockImpl.returnOrder = anOrder;
        databaseMockImpl.returnOrderItems.add(anOrderItem);
        databaseMockImpl.returnAccount = account;
        databaseMockImpl.returnBillingContacts.put(anOrder.Id, contact);
        
        PageReference pageReference = Page.CreateCustomer;
        Test.setCurrentPage(pageReference);
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, RESPONSE_STRING_ERROR2));
        pageReference.getParameters().put('ordId', String.valueOf(anOrder.Id));
        ApexPages.StandardController standardController = new ApexPages.StandardController(anOrder);
        CreateCustomerController controller = new CreateCustomerController(standardController, databaseMockImpl);
        
        Test.startTest();
        try {
            PageReference forwardPage = controller.createCustomer();
            System.assertNotEquals(forwardPage.getUrl(), null , 'URL must not be blank or null in order to create customer.');
        } catch (Exception eek) {
            System.debug('Error Message : ' + eek.getMessage() + 'At line number' + eek.getLineNumber() + 'Cause of Exception' + eek.getCause());
        }
        
        Test.stopTest();
        
        System.assertEquals(null, databaseMockImpl.insertedAccountLegalEntities, 'Account Legal Entity must not be null');
        //System.assertEquals('Success', databaseMockImpl.updatedOrder.Create_Customer_Result__c);
    }
    
    @isTest
    static void testCreateCustomerErrorNoContact() {
        Boolean doInsert = false;
        Map<String, SObject> sbObjectMap = TestUtilities.createToOrderStack(doInsert);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);
        blng__LegalEntity__c legalEntity = (blng__LegalEntity__c) sbObjectMap.get(TestUtilities.LEGAL_ENTITY);
        Order anOrder = (Order) sbObjectMap.get(TestUtilities.ORDER);
        OrderItem anOrderItem = (OrderItem) sbObjectMap.get(TestUtilities.ORDER_ITEM);
        anOrderItem.blng__LegalEntity__c = legalEntity.Id;
        anOrderItem.blng__LegalEntity__r = legalEntity;
        
        CreateCustomerControllerDatabaseMockImpl databaseMockImpl = new CreateCustomerControllerDatabaseMockImpl();
        databaseMockImpl.returnOrder = anOrder;
        databaseMockImpl.returnOrderItems.add(anOrderItem);
        databaseMockImpl.returnAccount = account;
        
        PageReference pageReference = Page.CreateCustomer;
        Test.setCurrentPage(pageReference);
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, RESPONSE_STRING_ERROR2));
        pageReference.getParameters().put('ordId', String.valueOf(anOrder.Id));
        ApexPages.StandardController standardController = new ApexPages.StandardController(anOrder);
        CreateCustomerController controller = new CreateCustomerController(standardController, databaseMockImpl);
        
        Test.startTest();
        try {
            PageReference forwardPage = controller.createCustomer();
            System.assertNotEquals(forwardPage.getUrl(), null , 'URL must not be blank or null in order to create customer.');
        } catch (Exception eek) {
            System.debug('Error Message : ' + eek.getMessage() + 'At line number' + eek.getLineNumber() + 'Cause of Exception' + eek.getCause());
        }
        
        Test.stopTest();
        
        System.assertEquals(null, databaseMockImpl.insertedAccountLegalEntities, 'Account legal entity cannot be null.');
        //System.assertEquals(1, databaseMockImpl.insertedAccountLegalEntities.size());
        System.assertEquals(null, databaseMockImpl.updatedOrder.Create_Customer_Result__c, 'For updating order Create customer result field cannot be blank');
    }
    
    @isTest
    static void testCreateCustomerSuccesDatabaseError() {
        Boolean doInsert = false;
        Map<String, SObject> sbObjectMap = TestUtilities.createToOrderStack(doInsert);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Contact contact = (Contact) sbObjectMap.get(TestUtilities.CONTACT);
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);
        blng__LegalEntity__c legalEntity = (blng__LegalEntity__c) sbObjectMap.get(TestUtilities.LEGAL_ENTITY);
        Order anOrder = (Order) sbObjectMap.get(TestUtilities.ORDER);
        OrderItem anOrderItem = (OrderItem) sbObjectMap.get(TestUtilities.ORDER_ITEM);
        anOrderItem.blng__LegalEntity__c = legalEntity.Id;
        anOrderItem.blng__LegalEntity__r = legalEntity;
        
        CreateCustomerControllerDatabaseMockImpl databaseMockImpl = new CreateCustomerControllerDatabaseMockImpl();
        databaseMockImpl.returnOrder = anOrder;
        databaseMockImpl.returnOrderItems.add(anOrderItem);
        databaseMockImpl.returnAccount = account;
        databaseMockImpl.returnBillingContacts.put(anOrder.Id, contact);
        databaseMockImpl.aleThrowException = true;
        
        PageReference pageReference = Page.CreateCustomer;
        Test.setCurrentPage(pageReference);
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, RESPONSE_STRING));
        pageReference.getParameters().put('ordId', String.valueOf(anOrder.Id));
        ApexPages.StandardController standardController = new ApexPages.StandardController(anOrder);
        CreateCustomerController controller = new CreateCustomerController(standardController, databaseMockImpl);
        
        Test.startTest();
        try {
            PageReference forwardPage = controller.createCustomer();
            System.assertNotEquals(forwardPage.getUrl(), null , 'URL must not be blank or null in order to create customer.');
        } catch (Exception eek) {
            System.debug('Error Message : ' + eek.getMessage() + 'At line number' + eek.getLineNumber() + 'Cause of Exception' + eek.getCause());
        }
        
        
        Test.stopTest();
        
        System.assertEquals(null, databaseMockImpl.insertedAccountLegalEntities, 'Account Legal entity cannot be null');
        //System.assertEquals('Success', databaseMockImpl.updatedOrder.Create_Customer_Result__c);
    }
    
    @isTest
    static void testCreateCustomerErrorAcctException() {
        Boolean doInsert = false;
        Map<String, SObject> sbObjectMap = TestUtilities.createToOrderStack(doInsert);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Contact contact = (Contact) sbObjectMap.get(TestUtilities.CONTACT);
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);
        blng__LegalEntity__c legalEntity = (blng__LegalEntity__c) sbObjectMap.get(TestUtilities.LEGAL_ENTITY);
        Order anOrder = (Order) sbObjectMap.get(TestUtilities.ORDER);
        OrderItem anOrderItem = (OrderItem) sbObjectMap.get(TestUtilities.ORDER_ITEM);
        anOrderItem.blng__LegalEntity__c = legalEntity.Id;
        anOrderItem.blng__LegalEntity__r = legalEntity;
        
        CreateCustomerControllerDatabaseMockImpl databaseMockImpl = new CreateCustomerControllerDatabaseMockImpl();
        databaseMockImpl.returnOrder = anOrder;
        databaseMockImpl.returnOrderItems.add(anOrderItem);
        databaseMockImpl.returnAccount = account;
        databaseMockImpl.returnBillingContacts.put(anOrder.Id, contact);
        databaseMockImpl.acctThrowException = true;
        
        PageReference pageReference = Page.CreateCustomer;
        Test.setCurrentPage(pageReference);
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, RESPONSE_STRING_ERROR2));
        pageReference.getParameters().put('ordId', String.valueOf(anOrder.Id));
        ApexPages.StandardController standardController = new ApexPages.StandardController(anOrder);
        CreateCustomerController controller = new CreateCustomerController(standardController, databaseMockImpl);
        
        Test.startTest();
        try {
            PageReference forwardPage = controller.createCustomer();
            System.assertNotEquals(forwardPage.getUrl(), null , 'URL must not be blank or null in order to create customer.');
        } catch (Exception eek) {
            System.debug('Error Message : ' + eek.getMessage() + 'At line number' + eek.getLineNumber() + 'Cause of Exception' + eek.getCause());
        }
        
        Test.stopTest();
        
        System.assertEquals(null, databaseMockImpl.insertedAccountLegalEntities, 'Legal Entity cannot be null');
        System.assertEquals(null, databaseMockImpl.updatedOrder.Create_Customer_Result__c, 'In order to update order Create Customer Result field cannot be null');
    }
    
    @isTest
    static void testCreateCustomerErrorOrderException() {
        Boolean doInsert = false;
        Map<String, SObject> sbObjectMap = TestUtilities.createToOrderStack(doInsert);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Contact contact = (Contact) sbObjectMap.get(TestUtilities.CONTACT);
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);
        blng__LegalEntity__c legalEntity = (blng__LegalEntity__c) sbObjectMap.get(TestUtilities.LEGAL_ENTITY);
        Order anOrder = (Order) sbObjectMap.get(TestUtilities.ORDER);
        OrderItem anOrderItem = (OrderItem) sbObjectMap.get(TestUtilities.ORDER_ITEM);
        anOrderItem.blng__LegalEntity__c = legalEntity.Id;
        anOrderItem.blng__LegalEntity__r = legalEntity;
        
        CreateCustomerControllerDatabaseMockImpl databaseMockImpl = new CreateCustomerControllerDatabaseMockImpl();
        databaseMockImpl.returnOrder = anOrder;
        databaseMockImpl.returnOrderItems.add(anOrderItem);
        databaseMockImpl.returnAccount = account;
        databaseMockImpl.returnBillingContacts.put(anOrder.Id, contact);
        databaseMockImpl.orderThrowException = true;
        
        PageReference pageReference = Page.CreateCustomer;
        Test.setCurrentPage(pageReference);
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, RESPONSE_STRING_ERROR2));
        pageReference.getParameters().put('ordId', String.valueOf(anOrder.Id));
        ApexPages.StandardController standardController = new ApexPages.StandardController(anOrder);
        CreateCustomerController controller = new CreateCustomerController(standardController, databaseMockImpl);
        
        Test.startTest();
        try {
			Account_Translated_FieldSet__c acc_ReqTrasaltedField = new Account_Translated_FieldSet__c ();
        acc_ReqTrasaltedField.account__c=account.Id;
        acc_ReqTrasaltedField.Translated_Account_Name__c = account.Name;
        acc_ReqTrasaltedField.Translated_Billing_Address_Line_1__c=account.BillingStreet;
        acc_ReqTrasaltedField.Translated_Billing_Address_Line_2__c=account.Billing_Address_Line_2__c;
        acc_ReqTrasaltedField.Translated_Billing_City__c=account.BillingCity;
        acc_ReqTrasaltedField.Translated_Billing_Country__c=account.BillingCountry;
        acc_ReqTrasaltedField.Translated_Billing_State_Province__c=account.BillingState;
        acc_ReqTrasaltedField.Translated_Billing_Zip_Postal_Code__c=account.BillingPostalCode;
        insert acc_ReqTrasaltedField;
            PageReference forwardPage = controller.createCustomer();
            System.assertNotEquals(forwardPage.getUrl(), null , 'URL must not be blank or null in order to create customer.');
        } catch (Exception eek) {
            System.debug('Error Message : ' + eek.getMessage() + 'At line number' + eek.getLineNumber() + 'Cause of Exception' + eek.getCause());
        }
        
        
        Test.stopTest();
        
        System.assertEquals(null, databaseMockImpl.insertedAccountLegalEntities, 'Account Legal Entity cannot be null ');
        System.assertEquals(null, databaseMockImpl.updatedOrder.Create_Customer_Result__c, 'In order to update order Create Customer Result field cannot be null');
    }
    
    private static String RESPONSE_STRING = '{'+
        '  \"Header\": {'+
        '    \"Systems\": {'+
        '      \"CallingApplication\": \"SFDC\",'+
        '      \"MessageDate\": \"2017-04-13\",'+
        '      \"MessageStatus\": \"OK\",'+
        '      \"MessageStatusText\": \"OK\"'+
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
    
    private static String RESPONSE_STRING_ERROR = '{'+
        '  \"Header\": {'+
        '    \"Systems\": {'+
        '      \"CallingApplication\": \"SFDC\",'+
        '      \"MessageDate\": \"2017-04-13\",'+
        '      \"MessageStatus\": \"ERROR\",'+
        '      \"MessageStatusText\": \"OK\"'+
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
        '  },\"Messages\": [{\"MessageReference\": \"test@informa.com\",\"MessageSeverity\": \"5\",\"MessageType\": \"Success\",\"MessageID\": \"0",\"MessageText\": \"Address Is Not Valid\"}]'+
        '}';
    
    private static String RESPONSE_STRING_ERROR2 = '{'+
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
        '  },'+
        '  \"Results\": {'+
        '    \"BusinessPartnerNumber\": \"\"'+
        '  },\"Messages\": [{\"MessageReference\": \"test@informa.com\",\"MessageSeverity\": \"5\",\"MessageType\": \"Success\",\"MessageID\": \"0",\"MessageText\": \"Address Is Not Valid\"}]'+
        '}';
    
    public class CreateCustomerControllerDatabaseMockImpl implements CreateCustomerController.CreateCustomerControllerDatabaseInterface  {
        public Order returnOrder;
        public List<OrderItem> returnOrderItems = new List<OrderItem>();
        public List<Account_Legal_Entity__c> returnAccountLegalEntities = new List<Account_Legal_Entity__c>();
        public Account returnAccount;
        public List<Account_Legal_Entity__c> insertedAccountLegalEntities;
        /*public List<Contact_Legal_Entity__c> insertContactLegalEntities;*/
        public Order updatedOrder;
        public Map<Id, Contact> returnBillingContacts = new Map<Id, Contact>();
        
        public Boolean acctThrowException = false;
        public Boolean aleThrowException = false;
        public Boolean orderThrowException = false;
        public Order queryOrderByOrderId(String orderId) {
            return returnOrder;
        }
        
        public List<OrderItem> queryOrderItemsByOrderId(String orderId) {
            return returnOrderItems;
        }
        
        public List<Account_Legal_Entity__c> queryAccountLegalEntitiesByAccountIdAndLegalEntityId(Id accountId, Set<Id> legalEntitySet) {
            return returnAccountLegalEntities;
        }
        
        public Account queryAccountByAccountId(String accountId) {
            if(acctThrowException) {
                throw new InformaExceptions.InformaHttpException(2222, 'Error when testing update Order');
            }
            return returnAccount;
        }
        
        public Map<Id, Contact> retrieveBillingContact(List<Id> orderIds) {
            System.debug('Retrieve billing Contract called.');
            return returnBillingContacts;
        }
        
        public void insertAccountLegalEntities(List<Account_Legal_Entity__c> accountLegalEntities) {
            if(aleThrowException) {
                throw new InformaExceptions.InformaHttpException(2222, 'Error when testing Account Legal Entities');
            }
            insertedAccountLegalEntities = accountLegalEntities;
        }
        
        public void updateOrder(Order anOrder) {
            if(orderThrowException) {
                throw new InformaExceptions.InformaHttpException(2222, 'Error when testing update Order');
            }
            updatedOrder = anOrder;
        }
    }
}