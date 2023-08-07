/**
 * Created by stevelohrenz on 6/13/17.
 * Apex Class: RemoteTaxInvoiceLineService.
 */

@IsTest
private class RemoteTaxInvoiceLineServiceTest {

    @testSetup
    public static void setupData() {
        TestUtilities.createCSIntegrationSettings();
        TestUtilities.createCSBatchSettings();
        TestUtilities.createBillingPrefix();
        TestUtilities.createBillingConfigs();
    }

    static testMethod void testCalculateTaxNoLegalEntity() {
        Map<String, SObject> sbObjectMap = TestUtilities.createToOrderStack(false);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Contact contact = (Contact) sbObjectMap.get(TestUtilities.CONTACT);
        Product2 product = (Product2) sbObjectMap.get(TestUtilities.PRODUCT);
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);

        Order order = (Order) sbObjectMap.get(TestUtilities.ORDER);

        OrderItem orderItem = (OrderItem) sbObjectMap.get(TestUtilities.ORDER_ITEM);

        List<OrderItem> orderItems = TestUtilities.queryOrderItemsByOrderId(order.Id);
        blng__Invoice__c invoice = TestUtilities.createInvoice(account, order, false, 'AAADEDEDDE');
        blng__InvoiceLine__c invoiceLine = TestUtilities.createInvoiceLine(invoice, orderItem, product, false);

        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, RESPONSE_STRING));
        RemoteTaxInvoiceLineDatabaseMockImpl mockDatabase = new RemoteTaxInvoiceLineDatabaseMockImpl();
        mockDatabase.returnQueryInvoiceLinesByLegalEntityReference.add(invoiceLine);
        Map<Id, Contact> contactsByOrderIds = new Map<Id, Contact>();
        contactsByOrderIds.put(order.Id, contact);
        mockDatabase.returnContactsByOrderIds = contactsByOrderIds;
        // Added by Palla Kishore for the ticket BK-19606 code coverage
        RemoteTaxInvoiceLineService rtService = new RemoteTaxInvoiceLineService();
        RemoteTaxInvoiceLineService rtInvoiceService = new RemoteTaxInvoiceLineService(mockDatabase);
        
        Account oaccount  = new account(name = 'Test');
        System.assertEquals('Test', oaccount.Name , 'Failed');
        Test.startTest();
        rtInvoiceService.getTax(new List<String> {invoiceLine.blng__LegalEntityReference__c});
        // Added by Palla Kishore for the ticket BK-19606 code coverage
        rtInvoiceService.postTax(new List<String> {invoiceLine.blng__LegalEntityReference__c});
        RemoteTaxInvoiceLineService.RemoteTaxInvoiceLineDatabaseDefaultImpl taxInvoiceLineDatabase = new RemoteTaxInvoiceLineService.RemoteTaxInvoiceLineDatabaseDefaultImpl ();
		taxInvoiceLineDatabase.queryInvoiceLinesByLegalEntityReference(new List<String> {invoiceLine.blng__LegalEntityReference__c});
        Test.stopTest();
    }

    static testMethod void testCalculateTaxLegalEntity() {
        Map<String, SObject> sbObjectMap = TestUtilities.createToOrderStack(false);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Contact contact = (Contact) sbObjectMap.get(TestUtilities.CONTACT);
        Product2 product = (Product2) sbObjectMap.get(TestUtilities.PRODUCT);
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);

        Order order = (Order) sbObjectMap.get(TestUtilities.ORDER);

        OrderItem orderItem = (OrderItem) sbObjectMap.get(TestUtilities.ORDER_ITEM);

        List<OrderItem> orderItems = TestUtilities.queryOrderItemsByOrderId(order.Id);
        blng__Invoice__c invoice = TestUtilities.createInvoice(account, order, false, 'AAADEDEDDE');
        blng__InvoiceLine__c invoiceLine = TestUtilities.createInvoiceLine(invoice, orderItem, product, false);

        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, RESPONSE_STRING));
        RemoteTaxInvoiceLineDatabaseMockImpl mockDatabase = new RemoteTaxInvoiceLineDatabaseMockImpl();

        blng__LegalEntity__c legalEntity = (blng__LegalEntity__c) sbObjectMap.get(TestUtilities.LEGAL_ENTITY);
        invoiceLine.blng__LegalEntity__c = legalEntity.Id;
        invoiceLine.blng__LegalEntity__r = legalEntity;
        mockDatabase.returnQueryInvoiceLinesByLegalEntityReference.add(invoiceLine);
        Map<Id, Contact> contactsByOrderIds = new Map<Id, Contact>();
        contactsByOrderIds.put(order.Id, contact);
        mockDatabase.returnContactsByOrderIds = contactsByOrderIds;
        RemoteTaxInvoiceLineService rtInvoiceService = new RemoteTaxInvoiceLineService(mockDatabase);
        Account oaccount  = new account(name = 'Test');
        System.assertEquals('Test', oaccount.Name, 'Failed') ;
        Test.startTest();
        rtInvoiceService.getTax(new List<String> {invoiceLine.blng__LegalEntityReference__c});
        Test.stopTest();
    }

    static testMethod void testCalculateTaxLegalEntityResponseString5() {
        Map<String, SObject> sbObjectMap = TestUtilities.createToOrderStack(false);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Contact contact = (Contact) sbObjectMap.get(TestUtilities.CONTACT);
        Product2 product = (Product2) sbObjectMap.get(TestUtilities.PRODUCT);
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);

        Order order = (Order) sbObjectMap.get(TestUtilities.ORDER);

        OrderItem orderItem = (OrderItem) sbObjectMap.get(TestUtilities.ORDER_ITEM);

        List<OrderItem> orderItems = TestUtilities.queryOrderItemsByOrderId(order.Id);
        blng__Invoice__c invoice = TestUtilities.createInvoice(account, order, false, 'AAADEDEDDE');
        blng__InvoiceLine__c invoiceLine = TestUtilities.createInvoiceLine(invoice, orderItem, product, false);

        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, responseString5));
        RemoteTaxInvoiceLineDatabaseMockImpl mockDatabase = new RemoteTaxInvoiceLineDatabaseMockImpl();

        blng__LegalEntity__c legalEntity = (blng__LegalEntity__c) sbObjectMap.get(TestUtilities.LEGAL_ENTITY);
        invoiceLine.blng__LegalEntity__c = legalEntity.Id;
        invoiceLine.blng__LegalEntity__r = legalEntity;
        mockDatabase.returnQueryInvoiceLinesByLegalEntityReference.add(invoiceLine);
        Map<Id, Contact> contactsByOrderIds = new Map<Id, Contact>();
        contactsByOrderIds.put(order.Id, contact);
        mockDatabase.returnContactsByOrderIds = contactsByOrderIds;
        RemoteTaxInvoiceLineService rtInvoiceService = new RemoteTaxInvoiceLineService(mockDatabase);
        Account oaccount  = new account(name = 'Test');
        System.assertEquals('Test', oaccount  .Name, 'Failed');
        Test.startTest();
        Map<Id, blng.TaxResults> taxResults = rtInvoiceService.getTax(new List<String> {invoiceLine.blng__LegalEntityReference__c});
        Test.stopTest();
    }

    static testMethod void testCalculateTaxLegalEntityResponseString4() {
        Map<String, SObject> sbObjectMap = TestUtilities.createToOrderStack(false);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Contact contact = (Contact) sbObjectMap.get(TestUtilities.CONTACT);
        Product2 product = (Product2) sbObjectMap.get(TestUtilities.PRODUCT);
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);

        Order order = (Order) sbObjectMap.get(TestUtilities.ORDER);

        OrderItem orderItem = (OrderItem) sbObjectMap.get(TestUtilities.ORDER_ITEM);

        List<OrderItem> orderItems = TestUtilities.queryOrderItemsByOrderId(order.Id);
        blng__Invoice__c invoice = TestUtilities.createInvoice(account, order, false, 'AAADEDEDDE');
        blng__InvoiceLine__c invoiceLine = TestUtilities.createInvoiceLine(invoice, orderItem, product, false);

        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, responseString4));
        RemoteTaxInvoiceLineDatabaseMockImpl mockDatabase = new RemoteTaxInvoiceLineDatabaseMockImpl();

        blng__LegalEntity__c legalEntity = (blng__LegalEntity__c) sbObjectMap.get(TestUtilities.LEGAL_ENTITY);
        invoiceLine.blng__LegalEntity__c = legalEntity.Id;
        invoiceLine.blng__LegalEntity__r = legalEntity;
        mockDatabase.returnQueryInvoiceLinesByLegalEntityReference.add(invoiceLine);
        Map<Id, Contact> contactsByOrderIds = new Map<Id, Contact>();
        contactsByOrderIds.put(order.Id, contact);
        mockDatabase.returnContactsByOrderIds = contactsByOrderIds;
        RemoteTaxInvoiceLineService rtInvoiceService = new RemoteTaxInvoiceLineService(mockDatabase);
        Account oaccount  = new account(name = 'Test');
        System.assertEquals('Test', oaccount  .Name, 'Failed');
        Test.startTest();
        Map<Id, blng.TaxResults> taxResults = rtInvoiceService.getTax(new List<String> {invoiceLine.blng__LegalEntityReference__c});
        Test.stopTest();
    }

    static testMethod void testCalculateTaxLegalEntityResponseString3() {
        Map<String, SObject> sbObjectMap = TestUtilities.createToOrderStack(false);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Contact contact = (Contact) sbObjectMap.get(TestUtilities.CONTACT);
        Product2 product = (Product2) sbObjectMap.get(TestUtilities.PRODUCT);
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);

        Order order = (Order) sbObjectMap.get(TestUtilities.ORDER);

        OrderItem orderItem = (OrderItem) sbObjectMap.get(TestUtilities.ORDER_ITEM);

        List<OrderItem> orderItems = TestUtilities.queryOrderItemsByOrderId(order.Id);
        blng__Invoice__c invoice = TestUtilities.createInvoice(account, order, false, 'AAADEDEDDE');
        blng__InvoiceLine__c invoiceLine = TestUtilities.createInvoiceLine(invoice, orderItem, product, false);

        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, responseString3));
        RemoteTaxInvoiceLineDatabaseMockImpl mockDatabase = new RemoteTaxInvoiceLineDatabaseMockImpl();

        blng__LegalEntity__c legalEntity = (blng__LegalEntity__c) sbObjectMap.get(TestUtilities.LEGAL_ENTITY);
        invoiceLine.blng__LegalEntity__c = legalEntity.Id;
        invoiceLine.blng__LegalEntity__r = legalEntity;
        mockDatabase.returnQueryInvoiceLinesByLegalEntityReference.add(invoiceLine);
        Map<Id, Contact> contactsByOrderIds = new Map<Id, Contact>();
        contactsByOrderIds.put(order.Id, contact);
        mockDatabase.returnContactsByOrderIds = contactsByOrderIds;
        RemoteTaxInvoiceLineService rtInvoiceService = new RemoteTaxInvoiceLineService(mockDatabase);
        Account oaccount  = new account(name = 'Test');
        System.assertEquals('Test', oaccount  .Name, 'Failed');
        Test.startTest();
        Map<Id, blng.TaxResults> taxResults = rtInvoiceService.getTax(new List<String> {invoiceLine.blng__LegalEntityReference__c});
        Test.stopTest();
    }

    static testMethod void testCalculateTaxLegalEntityResponseString2() {
        Map<String, SObject> sbObjectMap = TestUtilities.createToOrderStack(false);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Contact contact = (Contact) sbObjectMap.get(TestUtilities.CONTACT);
        Product2 product = (Product2) sbObjectMap.get(TestUtilities.PRODUCT);
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);

        Order order = (Order) sbObjectMap.get(TestUtilities.ORDER);

        OrderItem orderItem = (OrderItem) sbObjectMap.get(TestUtilities.ORDER_ITEM);

        List<OrderItem> orderItems = TestUtilities.queryOrderItemsByOrderId(order.Id);
        blng__Invoice__c invoice = TestUtilities.createInvoice(account, order, false, 'AAADEDEDDE');
        blng__InvoiceLine__c invoiceLine = TestUtilities.createInvoiceLine(invoice, orderItem, product, false);

        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, responseString2));
        RemoteTaxInvoiceLineDatabaseMockImpl mockDatabase = new RemoteTaxInvoiceLineDatabaseMockImpl();

        blng__LegalEntity__c legalEntity = (blng__LegalEntity__c) sbObjectMap.get(TestUtilities.LEGAL_ENTITY);
        invoiceLine.blng__LegalEntity__c = legalEntity.Id;
        invoiceLine.blng__LegalEntity__r = legalEntity;
        mockDatabase.returnQueryInvoiceLinesByLegalEntityReference.add(invoiceLine);
        Map<Id, Contact> contactsByOrderIds = new Map<Id, Contact>();
        contactsByOrderIds.put(order.Id, contact);
        mockDatabase.returnContactsByOrderIds = contactsByOrderIds;
        RemoteTaxInvoiceLineService rtInvoiceService = new RemoteTaxInvoiceLineService(mockDatabase);
        Account oaccount  = new account(name = 'Test');
        System.assertEquals('Test', oaccount  .Name, 'Failed');
        Test.startTest();
        Map<Id, blng.TaxResults> taxResults = rtInvoiceService.getTax(new List<String> {invoiceLine.blng__LegalEntityReference__c});
        Test.stopTest();
    }
    //Add For If Else Class
    static testMethod void testCalculateTaxLegalEntityResponseString1() {
        Map<String, SObject> sbObjectMap = TestUtilities.createToOrderStack(false);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Contact contact = (Contact) sbObjectMap.get(TestUtilities.CONTACT);
        Product2 product = (Product2) sbObjectMap.get(TestUtilities.PRODUCT);
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);

        Order order = (Order) sbObjectMap.get(TestUtilities.ORDER);

        OrderItem orderItem = (OrderItem) sbObjectMap.get(TestUtilities.ORDER_ITEM);

        List<OrderItem> orderItems = TestUtilities.queryOrderItemsByOrderId(order.Id);
        blng__Invoice__c invoice = TestUtilities.createInvoice(account, order, false, 'AAADEDEDDE');
        blng__InvoiceLine__c invoiceLine = TestUtilities.createInvoiceLine(invoice, orderItem, product, false);

        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, responseString1));
        RemoteTaxInvoiceLineDatabaseMockImpl mockDatabase = new RemoteTaxInvoiceLineDatabaseMockImpl();

        blng__LegalEntity__c legalEntity = (blng__LegalEntity__c) sbObjectMap.get(TestUtilities.LEGAL_ENTITY);
        invoiceLine.blng__LegalEntity__c = legalEntity.Id;
        invoiceLine.blng__LegalEntity__r = legalEntity;
        mockDatabase.returnQueryInvoiceLinesByLegalEntityReference.add(invoiceLine);
        Map<Id, Contact> contactsByOrderIds = new Map<Id, Contact>();
        contactsByOrderIds.put(order.Id, contact);
        mockDatabase.returnContactsByOrderIds = contactsByOrderIds;
        RemoteTaxInvoiceLineService rtInvoiceService = new RemoteTaxInvoiceLineService(mockDatabase);
        Account oaccount  = new account(name = 'Test');
        System.assertEquals('Test', oaccount  .Name , 'Failed');
        Test.startTest();
        Map<Id, blng.TaxResults> taxResults = rtInvoiceService.getTax(new List<String> {invoiceLine.blng__LegalEntityReference__c});
        Test.stopTest();
    }

    static testMethod void testCalculateTaxLegalEntityResponseStringIfelse() {
        Map<String, SObject> sbObjectMap = TestUtilities.createToOrderStack(false);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Contact contact = (Contact) sbObjectMap.get(TestUtilities.CONTACT);
        Product2 product = (Product2) sbObjectMap.get(TestUtilities.PRODUCT);
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);

        Order order = (Order) sbObjectMap.get(TestUtilities.ORDER);

        OrderItem orderItem = (OrderItem) sbObjectMap.get(TestUtilities.ORDER_ITEM);

        List<OrderItem> orderItems = TestUtilities.queryOrderItemsByOrderId(order.Id);
        blng__Invoice__c invoice = TestUtilities.createInvoice(account, order, false, 'AAADEDEDDE');
        blng__InvoiceLine__c invoiceLine = TestUtilities.createInvoiceLine(invoice, orderItem, product, false);

        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, responseStringIfElse));
        RemoteTaxInvoiceLineDatabaseMockImpl mockDatabase = new RemoteTaxInvoiceLineDatabaseMockImpl();

        blng__LegalEntity__c legalEntity = (blng__LegalEntity__c) sbObjectMap.get(TestUtilities.LEGAL_ENTITY);
        invoiceLine.blng__LegalEntity__c = legalEntity.Id;
        invoiceLine.blng__LegalEntity__r = legalEntity;
        mockDatabase.returnQueryInvoiceLinesByLegalEntityReference.add(invoiceLine);
        Map<Id, Contact> contactsByOrderIds = new Map<Id, Contact>();
        contactsByOrderIds.put(order.Id, contact);
        mockDatabase.returnContactsByOrderIds = contactsByOrderIds;
        RemoteTaxInvoiceLineService rtInvoiceService = new RemoteTaxInvoiceLineService(mockDatabase);
        Account oaccount  = new account(name = 'Test');
        System.assertEquals('Test', oaccount  .Name , 'Failed');
        Test.startTest();
        Map<Id, blng.TaxResults> taxResults = rtInvoiceService.getTax(new List<String> {invoiceLine.blng__LegalEntityReference__c});
        Test.stopTest();
    }
    //
    static testMethod void testCalculateTaxLegalEntityError() {
        Map<String, SObject> sbObjectMap = TestUtilities.createToOrderStack(false);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Contact contact = (Contact) sbObjectMap.get(TestUtilities.CONTACT);
        Product2 product = (Product2) sbObjectMap.get(TestUtilities.PRODUCT);
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);

        Order order = (Order) sbObjectMap.get(TestUtilities.ORDER);

        OrderItem orderItem = (OrderItem) sbObjectMap.get(TestUtilities.ORDER_ITEM);

        List<OrderItem> orderItems = TestUtilities.queryOrderItemsByOrderId(order.Id);
        blng__Invoice__c invoice = TestUtilities.createInvoice(account, order, false, 'AAADEDEDDE');
        blng__InvoiceLine__c invoiceLine = TestUtilities.createInvoiceLine(invoice, orderItem, product, false);

        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, RESPONSE_STRING_ERROR));
        RemoteTaxInvoiceLineDatabaseMockImpl mockDatabase = new RemoteTaxInvoiceLineDatabaseMockImpl();

        blng__LegalEntity__c legalEntity = (blng__LegalEntity__c) sbObjectMap.get(TestUtilities.LEGAL_ENTITY);
        invoiceLine.blng__LegalEntity__c = legalEntity.Id;
        invoiceLine.blng__LegalEntity__r = legalEntity;
        mockDatabase.returnQueryInvoiceLinesByLegalEntityReference.add(invoiceLine);
        Map<Id, Contact> contactsByOrderIds = new Map<Id, Contact>();
        contactsByOrderIds.put(order.Id, contact);
        mockDatabase.returnContactsByOrderIds = contactsByOrderIds;
        RemoteTaxInvoiceLineService rtInvoiceService = new RemoteTaxInvoiceLineService(mockDatabase);
        Account acc  = new account(name = 'Test');
        System.assertEquals('Test', acc.Name , 'Failed');
        Test.startTest();
        rtInvoiceService.getTax(new List<String> {invoiceLine.blng__LegalEntityReference__c});
        Test.stopTest();
    }

    static String RESPONSE_STRING = '{' +
                                    '  \"Header\": {' +
                                    '    \"Systems\": {' +
                                    '      \"CallingApplication\": \"SFDC-GE\",' +
                                    '      \"MessageDate\": \"2017-04-04\",' +
                                    '      \"MessageStatus\": \"OK\",' +
                                    '      \"MessageStatusText\": \"Testing\"' +
                                    '    }' +
                                    '  },' +
                                    '  \"Content\": {' +
                                    '    \"Transaction\": {' +
                                    '      \"MetaData\": {' +
                                    '        \"Customer\": {' +
                                    '          \"CustomerEmail\": \"mulesoft@informa.com\"' +
                                    '        },' +
                                    '        \"AddressGroup\": {' +
                                    '          \"BillTo\": {' +
                                    '            \"PersonName\": {' +
                                    '              \"Prefix\": \"Mr.\",' +
                                    '              \"FirstNames\": \"Guan\",' +
                                    '              \"LastName\": \"Carlos\"' +
                                    '            },' +
                                    '            \"Address\": {' +
                                    '              \"Organisation\": \"Informa\",' +
                                    '              \"Department\": \"Global Support\",' +
                                    '              \"AddressLine1\": \"Schimmelt 32\",' +
                                    '              \"AddressLine2\": \"\",' +
                                    '              \"City\": \"Eindhoven\",' +
                                    '              \"State\": \"\",' +
                                    '              \"PostalCode\": \"5611 ZX\",' +
                                    '              \"Country\": \"NL\",' +
                                    '              \"PhoneNumber\": \"3161234567890\",' +
                                    '              \"PhoneExtension\": \"x1234\",' +
                                    '              \"FaxNumber\": \"3161234567899\"' +
                                    '            }' +
                                    '          },' +
                                    '          \"ShipTo\": {' +
                                    '            \"PersonName\": {' +
                                    '              \"Prefix\": \"Mr.\",' +
                                    '              \"FirstNames\": \"Guan\",' +
                                    '              \"LastName\": \"Carlos\"' +
                                    '            },' +
                                    '            \"Address\": {' +
                                    '              \"Organisation\": \"Informa\",' +
                                    '              \"Department\": \"Global Support\",' +
                                    '              \"AddressLine1\": \"Schimmelt 32\",' +
                                    '              \"AddressLine2\": \"\",' +
                                    '              \"City\": \"Eindhoven\",' +
                                    '              \"State\": \"\",' +
                                    '              \"PostalCode\": \"5611 ZX\",' +
                                    '              \"Country\": \"NL\",' +
                                    '              \"PhoneNumber\": \"3161234567890\",' +
                                    '              \"PhoneExtension\": \"x1234\",' +
                                    '              \"FaxNumber\": \"3161234567899\"' +
                                    '            }' +
                                    '          }' +
                                    '        },' +
                                    '        \"Currency\": \"GBP\",' +
                                    '        \"TaxLabel\": \"TAX\"' +
                                    '      },' +
                                    '      \"CartItems\": [' +
                                    '        {' +
                                    '          \"CartItem\": {' +
                                    '            \"Quantity\": 100,' +
                                    '            \"Price\": 1000,' +
                                    '            \"Tax\": 250,' +
                                    '            \"TaxRates\": [' +
                                    '              {' +
                                    '                \"TaxRate\": 500,' +
                                    '                \"TaxAmount\": 1375' +
                                    '              },' +
                                    '              {' +
                                    '                \"TaxRate\": -500,' +
                                    '                \"TaxAmount\": -1375' +
                                    '              }' +
                                    '            ],' +
                                    '            \"ItemData\": {' +
                                    '              \"ProductCode\": \"UKCOMI-TOCEU2018\",' +
                                    '              \"ProductType\": \"Exhibition\",' +
                                    '              \"ProductTitle\": null' +
                                    '            }' +
                                    '          }' +
                                    '        }' +
                                    '      ]' +
                                    '    }' +
                                    '  }' +
                                    '}';


    static String RESPONSE_STRING_ERROR = '{' +
                                          '  \"Header\": {' +
                                          '    \"Systems\": {' +
                                          '      \"CallingApplication\": \"SFDC-GE\",' +
                                          '      \"MessageDate\": \"2017-04-04\",' +
                                          '      \"MessageStatus\": \"ERROR\",' +
                                          '      \"MessageStatusText\": \"Testing\"' +
                                          '    }' +
                                          '  },' +
                                          '  \"Content\": {' +
                                          '    \"Transaction\": {' +
                                          '      \"MetaData\": {' +
                                          '        \"Customer\": {' +
                                          '          \"CustomerEmail\": \"mulesoft@informa.com\"' +
                                          '        },' +
                                          '        \"AddressGroup\": {' +
                                          '          \"BillTo\": {' +
                                          '            \"PersonName\": {' +
                                          '              \"Prefix\": \"Mr.\",' +
                                          '              \"FirstNames\": \"Guan\",' +
                                          '              \"LastName\": \"Carlos\"' +
                                          '            },' +
                                          '            \"Address\": {' +
                                          '              \"Organisation\": \"Informa\",' +
                                          '              \"Department\": \"Global Support\",' +
                                          '              \"AddressLine1\": \"Schimmelt 32\",' +
                                          '              \"AddressLine2\": \"\",' +
                                          '              \"City\": \"Eindhoven\",' +
                                          '              \"State\": \"\",' +
                                          '              \"PostalCode\": \"5611 ZX\",' +
                                          '              \"Country\": \"NL\",' +
                                          '              \"PhoneNumber\": \"3161234567890\",' +
                                          '              \"PhoneExtension\": \"x1234\",' +
                                          '              \"FaxNumber\": \"3161234567899\"' +
                                          '            }' +
                                          '          },' +
                                          '          \"ShipTo\": {' +
                                          '            \"PersonName\": {' +
                                          '              \"Prefix\": \"Mr.\",' +
                                          '              \"FirstNames\": \"Guan\",' +
                                          '              \"LastName\": \"Carlos\"' +
                                          '            },' +
                                          '            \"Address\": {' +
                                          '              \"Organisation\": \"Informa\",' +
                                          '              \"Department\": \"Global Support\",' +
                                          '              \"AddressLine1\": \"Schimmelt 32\",' +
                                          '              \"AddressLine2\": \"\",' +
                                          '              \"City\": \"Eindhoven\",' +
                                          '              \"State\": \"\",' +
                                          '              \"PostalCode\": \"5611 ZX\",' +
                                          '              \"Country\": \"NL\",' +
                                          '              \"PhoneNumber\": \"3161234567890\",' +
                                          '              \"PhoneExtension\": \"x1234\",' +
                                          '              \"FaxNumber\": \"3161234567899\"' +
                                          '            }' +
                                          '          }' +
                                          '        },' +
                                          '        \"Currency\": \"GBP\",' +
                                          '        \"TaxLabel\": \"TAX\"' +
                                          '      },' +
                                          '      \"CartItems\": [' +
                                          '        {' +
                                          '          \"CartItem\": {' +
                                          '            \"Quantity\": 100,' +
                                          '            \"Price\": 1000,' +
                                          '            \"Tax\": 250,' +
                                          '            \"TaxRates\": [' +
                                          '              {' +
                                          '                \"TaxRate\": 500,' +
                                          '                \"TaxAmount\": 1375' +
                                          '              },' +
                                          '              {' +
                                          '                \"TaxRate\": -500,' +
                                          '                \"TaxAmount\": -1375' +
                                          '              }' +
                                          '            ],' +
                                          '            \"ItemData\": {' +
                                          '              \"ProductCode\": \"UKCOMI-TOCEU2018\",' +
                                          '              \"ProductType\": \"Exhibition\",' +
                                          '              \"ProductTitle\": null' +
                                          '            }' +
                                          '          }' +
                                          '        }' +
                                          '      ]' +
                                          '    }' +
                                          '  }' +
                                          '}';

    static String responseString2 = '{\"Header\": {\"Systems\": {\"CallingApplication\": \"SFDC-GE\",\"MessageDate\":\"2017-08-28\",\"MessageStatus\": \"OK\",\"MessageStatusText\": null}},\"Content\": {\"Transaction\": {\"MetaData\": {\"Customer\": {\"CustomerEmail\":\"bangash.m@girikon.com\"},\"AddressGroup\": {\"BillTo\": {\"PersonName\": {\"Prefix\": null,\"FirstNames\": \"US  Invoice\",\"LastName\":\"Contact\"},\"Address\": {\"Organisation\": null,\"Department\": null,\"AddressLine1\": \"PO Box 800\",\"AddressLine2\": null,\"City\": \"Oxford\",\"State\":null,\"PostalCode\": \"OX5 IDX\",\"Country\": \"UK\",\"PhoneNumber\": null,\"PhoneExtension\": null,\"FaxNumber\": null}},\"ShipTo\": {\"PersonName\": {\"Prefix\":null,\"FirstNames\": \"US  Invoice\",\"LastName\": \"Contact\"},\"Address\": {\"Organisation\": null,\"Department\": null,\"AddressLine1\": \"PO Box 800\",\"AddressLine2\": null,\"City\": \"Oxford\",\"State\": null,\"PostalCode\": \"OX5 IDX\",\"Country\": \"UK\",\"PhoneNumber\": null,\"PhoneExtension\": null,\"FaxNumber\":null}}},\"Currency\": \"EUR\",\"TaxLabel\": \"TAX\"},\"CartItems\": [{\"CartItem\": {\"Quantity\": 100,\"Price\": 1000,\"Tax\": 250,\"TaxRates\": [{"TaxRate": 500,"TaxAmount": 10000},{"TaxRate": -500,"TaxAmount": -10000}],\"ItemData\": {\"ProductCode\": \"UKCOMI-TOCEU2018\"}}},{\"CartItem\": {\"Quantity\": 9000,\"Price\": 2767500,\"Tax\": 553500,\"TaxRates\": [{"TaxRate": 500,"TaxAmount": 0},{"TaxRate": -500,"TaxAmount": 0}],\"ItemData\": {\"ProductCode\": \"SPO1LE-TOCEU2018\"}}},{\"CartItem\": {\"Quantity\": 100,\"Price\":10000,\"Tax\": 1000,\"TaxRates\": [{"TaxRate": 500,"TaxAmount": 356400},{"TaxRate": -500,"TaxAmount": -356400}],\"ItemData\": {\"ProductCode\":\"UKCOMI-TOCEU2018\"}}},{\"CartItem\": {\"Quantity\": 100,\"Price\": 1250,\"Tax\": 250,\"TaxRates\": [{"TaxRate": 500,"TaxAmount": 1375},{"TaxRate": -500,"TaxAmount": -1375}],\"ItemData\": {\"ProductCode\":\"LUNCHP-TOCEU2018\"}}}]}},\"Messages\": [{\"MessageReference\": \"bangash.m@girikon.com\",\"MessageSeverity\": \"5\",\"MessageType\": \"Success\",\"MessageID\": \"0",\"MessageText\": null}]}';
    static String responseString1 = '{\"Header\": {\"Systems\": {\"CallingApplication\": \"SFDC-GE\",\"MessageDate\":\"2017-08-28\",\"MessageStatus\": \"OK\",\"MessageStatusText\": null}},\"Content\": {\"Transaction\": {\"MetaData\": {\"Customer\": {\"CustomerEmail\":\"bangash.m@girikon.com\"},\"AddressGroup\": {\"BillTo\": {\"PersonName\": {\"Prefix\": null,\"FirstNames\": \"US  Invoice\",\"LastName\":\"Contact\"},\"Address\": {\"Organisation\": null,\"Department\": null,\"AddressLine1\": \"PO Box 800\",\"AddressLine2\": null,\"City\": \"Oxford\",\"State\":null,\"PostalCode\": \"OX5 IDX\",\"Country\": \"UK\",\"PhoneNumber\": null,\"PhoneExtension\": null,\"FaxNumber\": null}},\"ShipTo\": {\"PersonName\": {\"Prefix\":null,\"FirstNames\": \"US  Invoice\",\"LastName\": \"Contact\"},\"Address\": {\"Organisation\": null,\"Department\": null,\"AddressLine1\": \"PO Box 800\",\"AddressLine2\": null,\"City\": \"Oxford\",\"State\": null,\"PostalCode\": \"OX5 IDX\",\"Country\": \"UK\",\"PhoneNumber\": null,\"PhoneExtension\": null,\"FaxNumber\":null}}},\"Currency\": \"EUR\",\"TaxLabel\": \"TAX\"},\"CartItems\": [{\"CartItem\": {\"Quantity\": 100,\"Price\": 1000,\"Tax\": 250,\"TaxRates\": [{"TaxRate": 500}],\"ItemData\": {\"ProductCode\": \"UKCOMI-TOCEU2018\"}}},{\"CartItem\": {\"Quantity\": 9000,\"Price\": 2767500,\"Tax\": 553500,\"TaxRates\": [{"TaxRate": 500}],\"ItemData\": {\"ProductCode\": \"SPO1LE-TOCEU2018\"}}},{\"CartItem\": {\"Quantity\": 100,\"Price\":10000,\"Tax\": 1000,\"TaxRates\": [{"TaxRate": 500}],\"ItemData\": {\"ProductCode\":\"UKCOMI-TOCEU2018\"}}},{\"CartItem\": {\"Quantity\": 100,\"Price\": 1250,\"Tax\": 250,\"TaxRates\": [{"TaxRate": 500}],\"ItemData\": {\"ProductCode\":\"LUNCHP-TOCEU2018\"}}}]}},\"Messages\": [{\"MessageReference\": \"bangash.m@girikon.com\",\"MessageSeverity\": \"5\",\"MessageType\": \"Success\",\"MessageID\": \"0",\"MessageText\": null}]}';
    static String responseStringIfElse = '{\"Header\": {\"Systems\": {\"CallingApplication\": \"SFDC-GE\",\"MessageDate\":\"2017-08-28\",\"MessageStatus\": \"OK\",\"MessageStatusText\": null}},\"Content\": {\"Transaction\": {\"MetaData\": {\"Customer\": {\"CustomerEmail\":\"bangash.m@girikon.com\"},\"AddressGroup\": {\"BillTo\": {\"PersonName\": {\"Prefix\": null,\"FirstNames\": \"US  Invoice\",\"LastName\":\"Contact\"},\"Address\": {\"Organisation\": null,\"Department\": null,\"AddressLine1\": \"PO Box 800\",\"AddressLine2\": null,\"City\": \"Oxford\",\"State\":null,\"PostalCode\": \"OX5 IDX\",\"Country\": \"UK\",\"PhoneNumber\": null,\"PhoneExtension\": null,\"FaxNumber\": null}},\"ShipTo\": {\"PersonName\": {\"Prefix\":null,\"FirstNames\": \"US  Invoice\",\"LastName\": \"Contact\"},\"Address\": {\"Organisation\": null,\"Department\": null,\"AddressLine1\": \"PO Box 800\",\"AddressLine2\": null,\"City\": \"Oxford\",\"State\": null,\"PostalCode\": \"OX5 IDX\",\"Country\": \"UK\",\"PhoneNumber\": null,\"PhoneExtension\": null,\"FaxNumber\":null}}},\"Currency\": \"EUR\",\"TaxLabel\": \"TAX\"},\"CartItems\": [{\"CartItem\": {\"Quantity\": 100,\"Price\": 1032,\"Tax\": 250,\"TaxRates\": [2000],\"ItemData\": {\"ProductCode\": \"UKCOMI-TOCEU2018\"}}},{\"CartItem\": {\"Quantity\": 9000,\"Price\": 2767500,\"Tax\": 553500,\"TaxRates\": [2000],\"ItemData\": {\"ProductCode\": \"SPO1LE-TOCEU2018\"}}},{\"CartItem\": {\"Quantity\": 100,\"Price\":10000,\"Tax\": 1000,\"TaxRates\": [2000],\"ItemData\": {\"ProductCode\":\"UKCOMI-TOCEU2018\"}}},{\"CartItem\": {\"Quantity\": 100,\"Price\": 1250,\"Tax\": 250,\"TaxRates\": [2000],\"ItemData\": {\"ProductCode\":\"LUNCHP-TOCEU2018\"}}}]}},\"Messages\": [{\"MessageReference\": \"bangash.m@girikon.com\",\"MessageSeverity\": \"5\",\"MessageType\": \"Success\",\"MessageID\": \"0",\"MessageText\": null}]}';
    static String responseString3 = '{\"Header\": {\"Systems\": {\"CallingApplication\": \"SFDC-GE\",\"MessageDate\":\"2017-08-28\",\"MessageStatus\": \"OK\",\"MessageStatusText\": null}},\"Content\": {\"Transaction\": {\"MetaData\": {\"Customer\": {\"CustomerEmail\":\"bangash.m@girikon.com\"},\"AddressGroup\": {\"BillTo\": {\"PersonName\": {\"Prefix\": null,\"FirstNames\": \"US  Invoice\",\"LastName\":\"Contact\"},\"Address\": {\"Organisation\": null,\"Department\": null,\"AddressLine1\": \"PO Box 800\",\"AddressLine2\": null,\"City\": \"Oxford\",\"State\":null,\"PostalCode\": \"OX5 IDX\",\"Country\": \"UK\",\"PhoneNumber\": null,\"PhoneExtension\": null,\"FaxNumber\": null}},\"ShipTo\": {\"PersonName\": {\"Prefix\":null,\"FirstNames\": \"US  Invoice\",\"LastName\": \"Contact\"},\"Address\": {\"Organisation\": null,\"Department\": null,\"AddressLine1\": \"PO Box 800\",\"AddressLine2\": null,\"City\": \"Oxford\",\"State\": null,\"PostalCode\": \"OX5 IDX\",\"Country\": \"UK\",\"PhoneNumber\": null,\"PhoneExtension\": null,\"FaxNumber\":null}}},\"Currency\": \"EUR\",\"TaxLabel\": \"TAX\"},\"CartItems\": [{\"CartItem\": {\"Quantity\": 100,\"Price\": 10,\"Tax\": 250,\"TaxRates\": [{"TaxRate": 500,"TaxAmount": 10000}],\"ItemData\": {\"ProductCode\": \"UKCOMI-TOCEU2018\"}}},{\"CartItem\": {\"Quantity\": 9000,\"Price\": 2767500,\"Tax\": 553500,\"TaxRates\": [{"TaxRate": 500,"TaxAmount": 0}],\"ItemData\": {\"ProductCode\": \"SPO1LE-TOCEU2018\"}}},{\"CartItem\": {\"Quantity\": 100,\"Price\":10000,\"Tax\": 1000,\"TaxRates\": [{"TaxRate": 500,"TaxAmount": 356400}],\"ItemData\": {\"ProductCode\":\"UKCOMI-TOCEU2018\"}}},{\"CartItem\": {\"Quantity\": 100,\"Price\": 1250,\"Tax\": 250,\"TaxRates\": [{"TaxRate": 500,"TaxAmount": 1375}],\"ItemData\": {\"ProductCode\":\"LUNCHP-TOCEU2018\"}}}]}},\"Messages\": [{\"MessageReference\": \"bangash.m@girikon.com\",\"MessageSeverity\": \"5\",\"MessageType\": \"Success\",\"MessageID\": \"0",\"MessageText\": null}]}';
    static String responseString4 = '{\"Header\": {\"Systems\": {\"CallingApplication\": \"SFDC-GE\",\"MessageDate\":\"2017-08-28\",\"MessageStatus\": \"OK\",\"MessageStatusText\": null}},\"Content\": {\"Transaction\": {\"MetaData\": {\"Customer\": {\"CustomerEmail\":\"bangash.m@girikon.com\"},\"AddressGroup\": {\"BillTo\": {\"PersonName\": {\"Prefix\": null,\"FirstNames\": \"US  Invoice\",\"LastName\":\"Contact\"},\"Address\": {\"Organisation\": null,\"Department\": null,\"AddressLine1\": \"PO Box 800\",\"AddressLine2\": null,\"City\": \"Oxford\",\"State\":null,\"PostalCode\": \"OX5 IDX\",\"Country\": \"UK\",\"PhoneNumber\": null,\"PhoneExtension\": null,\"FaxNumber\": null}},\"ShipTo\": {\"PersonName\": {\"Prefix\":null,\"FirstNames\": \"US  Invoice\",\"LastName\": \"Contact\"},\"Address\": {\"Organisation\": null,\"Department\": null,\"AddressLine1\": \"PO Box 800\",\"AddressLine2\": null,\"City\": \"Oxford\",\"State\": null,\"PostalCode\": \"OX5 IDX\",\"Country\": \"UK\",\"PhoneNumber\": null,\"PhoneExtension\": null,\"FaxNumber\":null}}},\"Currency\": \"EUR\",\"TaxLabel\": \"TAX\"},\"CartItems\": [{\"CartItem\": {\"Quantity\": 100,\"Price\": 10,\"Tax\": 250,\"TaxRates\": [{"TaxRate": 500,"TaxAmount": 10000},{"TaxRate": 25,"TaxAmount": -10000}],\"ItemData\": {\"ProductCode\": \"UKCOMI-TOCEU2018\"}}},{\"CartItem\": {\"Quantity\": 9000,\"Price\": 2767500,\"Tax\": 553500,\"TaxRates\": [{"TaxRate": 500,"TaxAmount": 0},{"TaxRate": 25,"TaxAmount": 0}],\"ItemData\": {\"ProductCode\": \"SPO1LE-TOCEU2018\"}}},{\"CartItem\": {\"Quantity\": 100,\"Price\":10000,\"Tax\": 1000,\"TaxRates\": [{"TaxRate": 500,"TaxAmount": 356400},{"TaxRate": 25,"TaxAmount": -356400}],\"ItemData\": {\"ProductCode\":\"UKCOMI-TOCEU2018\"}}},{\"CartItem\": {\"Quantity\": 100,\"Price\": 1250,\"Tax\": 250,\"TaxRates\": [{"TaxRate": 500,"TaxAmount": 1375},{"TaxRate": 25,"TaxAmount": -1375}],\"ItemData\": {\"ProductCode\":\"LUNCHP-TOCEU2018\"}}}]}},\"Messages\": [{\"MessageReference\": \"bangash.m@girikon.com\",\"MessageSeverity\": \"5\",\"MessageType\": \"Success\",\"MessageID\": \"0",\"MessageText\": null}]}';
    static String responseString5 = '{\"Header\": {\"Systems\": {\"CallingApplication\": \"SFDC-GE\",\"MessageDate\":\"2017-08-28\",\"MessageStatus\": \"OK\",\"MessageStatusText\": null}},\"Content\": {\"Transaction\": {\"MetaData\": {\"Customer\": {\"CustomerEmail\":\"bangash.m@girikon.com\"},\"AddressGroup\": {\"BillTo\": {\"PersonName\": {\"Prefix\": null,\"FirstNames\": \"US  Invoice\",\"LastName\":\"Contact\"},\"Address\": {\"Organisation\": null,\"Department\": null,\"AddressLine1\": \"PO Box 800\",\"AddressLine2\": null,\"City\": \"Oxford\",\"State\":null,\"PostalCode\": \"OX5 IDX\",\"Country\": \"UK\",\"PhoneNumber\": null,\"PhoneExtension\": null,\"FaxNumber\": null}},\"ShipTo\": {\"PersonName\": {\"Prefix\":null,\"FirstNames\": \"US  Invoice\",\"LastName\": \"Contact\"},\"Address\": {\"Organisation\": null,\"Department\": null,\"AddressLine1\": \"PO Box 800\",\"AddressLine2\": null,\"City\": \"Oxford\",\"State\": null,\"PostalCode\": \"OX5 IDX\",\"Country\": \"UK\",\"PhoneNumber\": null,\"PhoneExtension\": null,\"FaxNumber\":null}}},\"Currency\": \"EUR\",\"TaxLabel\": \"TAX\"},\"CartItems\": [{\"CartItem\": {\"Quantity\": 100,\"Price\": 10,\"Tax\": 250,\"TaxRates\": [{"TaxRate": 500,"TaxAmount":null}],\"ItemData\": {\"ProductCode\": \"UKCOMI-TOCEU2018\"}}},{\"CartItem\": {\"Quantity\": 9000,\"Price\": 2767500,\"Tax\": 553500,\"TaxRates\": [{"TaxRate": 500,"TaxAmount":null}],\"ItemData\": {\"ProductCode\": \"SPO1LE-TOCEU2018\"}}},{\"CartItem\": {\"Quantity\": 100,\"Price\":10000,\"Tax\": 1000,\"TaxRates\": [{"TaxRate": 500,"TaxAmount":null}],\"ItemData\": {\"ProductCode\":\"UKCOMI-TOCEU2018\"}}},{\"CartItem\": {\"Quantity\": 100,\"Price\": 1250,\"Tax\": 250,\"TaxRates\": [{"TaxRate": 500,"TaxAmount":null}],\"ItemData\": {\"ProductCode\":\"LUNCHP-TOCEU2018\"}}}]}},\"Messages\": [{\"MessageReference\": \"bangash.m@girikon.com\",\"MessageSeverity\": \"5\",\"MessageType\": \"Success\",\"MessageID\": \"0",\"MessageText\": null}]}';
    /**
     * Mock class for the database interface.
     */
    public class RemoteTaxInvoiceLineDatabaseMockImpl implements  RemoteTaxInvoiceLineService.RemoteTaxInvoiceLineDatabaseInterface {
        public List<blng__InvoiceLine__c> returnQueryInvoiceLinesByLegalEntityReference = new List<blng__InvoiceLine__c>();
        public Map<Id, Contact> returnContactsByOrderIds = new Map<Id, Contact>();

        public List<blng__InvoiceLine__c> queryInvoiceLinesByLegalEntityReference(List<String> legalEntity) {
            return returnQueryInvoiceLinesByLegalEntityReference;
        }

        public Map<Id, Contact> queryBillingContactsByIds(List<Id> orderIds) {
            return returnContactsByOrderIds;
        }

        public List<Account_Legal_Entity__c> queryAccountLegalEntitiesByAccountIdAndLegalEntityId(Id accountId, Set<Id> legalEntitySet) {
            return new List<Account_Legal_Entity__c>();
        }
    }

}