/**
* unit tests for the RemoteTaxOrderProductService
*
*/

@IsTest
private class RemoteTaxOrderProductServiceTest {
    @testSetup
    public static void setupData() {
        TestUtilities.createCSIntegrationSettings();
        TestUtilities.createCSBatchSettings();
        TestUtilities.createBillingPrefix();
        TestUtilities.createBillingConfigs();
    }

    static testMethod void testCalculateTax() {
        Map<String, SObject> sbObjectMap = TestUtilities.createToOrderStack(false);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Contact contact = (Contact) sbObjectMap.get(TestUtilities.CONTACT);
        Product2 product = (Product2) sbObjectMap.get(TestUtilities.PRODUCT);
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);
        System.assertEquals(opportunity.Id, opportunity.id,'opportunity not created');
        Order order = (Order) sbObjectMap.get(TestUtilities.ORDER);
        OrderItem orderItem = (OrderItem) sbObjectMap.get(TestUtilities.ORDER_ITEM);
        blng__LegalEntity__c legalEntity = (blng__LegalEntity__c) sbObjectMap.get(TestUtilities.LEGAL_ENTITY);
        List<OrderItem> orderItems = new List<OrderItem> {orderItem};

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, responseString));
        RemoteTaxOrderProductDatabaseMockImpl mockDatabase = new RemoteTaxOrderProductDatabaseMockImpl();
        mockDatabase.returnQueryOrderItemByLegalEntityReference.add(orderItem);
        Map<Id, Contact> contactsByOrderIds = new Map<Id, Contact>();
        contactsByOrderIds.put(order.Id, contact);
        mockDatabase.returnContactsByOrderIds = contactsByOrderIds;
        RemoteTaxOrderProductService rtOrderItemService = new RemoteTaxOrderProductService(mockDatabase);
        Map<Id, blng.TaxResults> taxResults;
        try {
            taxResults = rtOrderItemService.getTax(new List<String> {
                orderItems.get(0).blng__LegalEntityReference__c
            });

        } catch (Exception eek) {
            System.debug(LoggingLevel.ERROR, 'RemoteTaxOrderProductServiceTest exception: ' + eek.getMessage());
        }
        Test.stopTest();
    }

    static testMethod void testCalculateTaxError() {
        Map<String, SObject> sbObjectMap = TestUtilities.createToOrderStack(false);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Contact contact = (Contact) sbObjectMap.get(TestUtilities.CONTACT);
        Product2 product = (Product2) sbObjectMap.get(TestUtilities.PRODUCT);
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);
        System.assertEquals(opportunity.Id, opportunity.id,'opportunity not created');
        Order order = (Order) sbObjectMap.get(TestUtilities.ORDER);
        OrderItem orderItem = (OrderItem) sbObjectMap.get(TestUtilities.ORDER_ITEM);
        blng__LegalEntity__c legalEntity = (blng__LegalEntity__c) sbObjectMap.get(TestUtilities.LEGAL_ENTITY);
        List<OrderItem> orderItems = new List<OrderItem> {orderItem};

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, responseStringError));
        RemoteTaxOrderProductDatabaseMockImpl mockDatabase = new RemoteTaxOrderProductDatabaseMockImpl();
        mockDatabase.returnQueryOrderItemByLegalEntityReference.add(orderItem);
        Map<Id, Contact> contactsByOrderIds = new Map<Id, Contact>();
        contactsByOrderIds.put(order.Id, contact);
        mockDatabase.returnContactsByOrderIds = contactsByOrderIds;
        RemoteTaxOrderProductService rtOrderItemService = new RemoteTaxOrderProductService(mockDatabase);
        Map<Id, blng.TaxResults> taxResults;
        try {
            taxResults = rtOrderItemService.getTax(new List<String> {
                orderItems.get(0).blng__LegalEntityReference__c
            });

        } catch (Exception eek) {
            System.debug(LoggingLevel.ERROR, 'RemoteTaxOrderProductServiceTest exception: ' + eek.getMessage());
        }
        Test.stopTest();
    }

    static testMethod void testCalculateTaxMissingLegalEntity() {
        Map<String, SObject> sbObjectMap = TestUtilities.createToOrderStack(false);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Contact contact = (Contact) sbObjectMap.get(TestUtilities.CONTACT);
        Product2 product = (Product2) sbObjectMap.get(TestUtilities.PRODUCT);
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);
        System.assertEquals(opportunity.Id, opportunity.id,'opportunity not created');
        Order order = (Order) sbObjectMap.get(TestUtilities.ORDER);
        OrderItem orderItem = (OrderItem) sbObjectMap.get(TestUtilities.ORDER_ITEM);
        blng__LegalEntity__c legalEntity = (blng__LegalEntity__c) sbObjectMap.get(TestUtilities.LEGAL_ENTITY);
        List<OrderItem> orderItems = new List<OrderItem> {orderItem};

        Test.startTest();
        for (OrderItem anOrderItem : orderItems) {
            anOrderItem.blng__LegalEntity__c = null;

        }
        //update orderItems;
        System.debug('OrderItems: ' + orderItems);
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, responseString));
        RemoteTaxOrderProductDatabaseMockImpl mockDatabase = new RemoteTaxOrderProductDatabaseMockImpl();
        mockDatabase.returnQueryOrderItemByLegalEntityReference.add(orderItem);
        Map<Id, Contact> contactsByOrderIds = new Map<Id, Contact>();
        contactsByOrderIds.put(order.Id, contact);
        mockDatabase.returnContactsByOrderIds = contactsByOrderIds;
        RemoteTaxOrderProductService rtOrderItemService = new RemoteTaxOrderProductService(mockDatabase);
        Map<Id, blng.TaxResults> taxResults;
        try {
            taxResults = rtOrderItemService.getTax(new List<String> {
                orderItems.get(0).blng__LegalEntityReference__c
            });
        } catch (Exception eek) {
            System.debug('Error :::  ' + eek.getMessage());
        }
        Test.stopTest();
    }

    static testMethod void testResponseString() {
        CalculateTaxResponse calcTaxResponse = CalculateTaxResponse.parse(responseString);
        System.assertEquals('OK', calcTaxResponse.Header.Systems.MessageStatus,'Nt Ok response');
    }

    static testMethod void testResponseStringError() {
        CalculateTaxResponse calcTaxResponse = CalculateTaxResponse.parse(responseStringError);
        System.assertEquals('99', calcTaxResponse.Messages.get(0).MessageID,'Error in response');
    }
    
    static testMethod void testCalculateTaxResponseString5() {
        Map<String, SObject> sbObjectMap = TestUtilities.createToOrderStack(false);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Contact contact = (Contact) sbObjectMap.get(TestUtilities.CONTACT);
        Product2 product = (Product2) sbObjectMap.get(TestUtilities.PRODUCT);
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);
        Order order = (Order) sbObjectMap.get(TestUtilities.ORDER);
        OrderItem orderItem = (OrderItem) sbObjectMap.get(TestUtilities.ORDER_ITEM);
        blng__LegalEntity__c legalEntity = (blng__LegalEntity__c) sbObjectMap.get(TestUtilities.LEGAL_ENTITY);
        List<OrderItem> orderItems = new List<OrderItem> {orderItem};

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, responseString5));
        RemoteTaxOrderProductDatabaseMockImpl mockDatabase = new RemoteTaxOrderProductDatabaseMockImpl();
        mockDatabase.returnQueryOrderItemByLegalEntityReference.add(orderItem);
        Map<Id, Contact> contactsByOrderIds = new Map<Id, Contact>();
        contactsByOrderIds.put(order.Id, contact);
        System.assertEquals(opportunity.Id, opportunity.id,'opportunity not created');
        mockDatabase.returnContactsByOrderIds = contactsByOrderIds;
        RemoteTaxOrderProductService rtOrderItemService = new RemoteTaxOrderProductService(mockDatabase);
        Map<Id, blng.TaxResults> taxResults;
        try {
            taxResults = rtOrderItemService.getTax(new List<String> {
                orderItems.get(0).blng__LegalEntityReference__c
            });

        } catch (Exception eek) {
            System.debug(LoggingLevel.ERROR, 'RemoteTaxOrderProductServiceTest exception: ' + eek.getMessage());
        }
        Test.stopTest();
    }
    
    static testMethod void testCalculateTaxResponseString4() {
        Map<String, SObject> sbObjectMap = TestUtilities.createToOrderStack(false);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Contact contact = (Contact) sbObjectMap.get(TestUtilities.CONTACT);
        Product2 product = (Product2) sbObjectMap.get(TestUtilities.PRODUCT);
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);
        Order order = (Order) sbObjectMap.get(TestUtilities.ORDER);
        OrderItem orderItem = (OrderItem) sbObjectMap.get(TestUtilities.ORDER_ITEM);
        blng__LegalEntity__c legalEntity = (blng__LegalEntity__c) sbObjectMap.get(TestUtilities.LEGAL_ENTITY);
        List<OrderItem> orderItems = new List<OrderItem> {orderItem};

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, responseString4));
        RemoteTaxOrderProductDatabaseMockImpl mockDatabase = new RemoteTaxOrderProductDatabaseMockImpl();
        mockDatabase.returnQueryOrderItemByLegalEntityReference.add(orderItem);
        Map<Id, Contact> contactsByOrderIds = new Map<Id, Contact>();
        contactsByOrderIds.put(order.Id, contact);
        System.assertEquals(opportunity.Id, opportunity.id,'opportunity not created');
        mockDatabase.returnContactsByOrderIds = contactsByOrderIds;
        RemoteTaxOrderProductService rtOrderItemService = new RemoteTaxOrderProductService(mockDatabase);
        Map<Id, blng.TaxResults> taxResults;
        try {
            taxResults = rtOrderItemService.getTax(new List<String> {
                orderItems.get(0).blng__LegalEntityReference__c
            });

        } catch (Exception eek) {
            System.debug(LoggingLevel.ERROR, 'RemoteTaxOrderProductServiceTest exception: ' + eek.getMessage());
        }
        Test.stopTest();
    }

    static testMethod void testCalculateTaxResponseString3() {
        Map<String, SObject> sbObjectMap = TestUtilities.createToOrderStack(false);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Contact contact = (Contact) sbObjectMap.get(TestUtilities.CONTACT);
        Product2 product = (Product2) sbObjectMap.get(TestUtilities.PRODUCT);
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);
        Order order = (Order) sbObjectMap.get(TestUtilities.ORDER);
        OrderItem orderItem = (OrderItem) sbObjectMap.get(TestUtilities.ORDER_ITEM);
        blng__LegalEntity__c legalEntity = (blng__LegalEntity__c) sbObjectMap.get(TestUtilities.LEGAL_ENTITY);
        List<OrderItem> orderItems = new List<OrderItem> {orderItem};

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, responseString3));
        RemoteTaxOrderProductDatabaseMockImpl mockDatabase = new RemoteTaxOrderProductDatabaseMockImpl();
        mockDatabase.returnQueryOrderItemByLegalEntityReference.add(orderItem);
        Map<Id, Contact> contactsByOrderIds = new Map<Id, Contact>();
        contactsByOrderIds.put(order.Id, contact);
        mockDatabase.returnContactsByOrderIds = contactsByOrderIds;
        RemoteTaxOrderProductService rtOrderItemService = new RemoteTaxOrderProductService(mockDatabase);
        System.assertEquals(opportunity.Id, opportunity.id,'opportunity not created');
        Map<Id, blng.TaxResults> taxResults;
        try {
            taxResults = rtOrderItemService.getTax(new List<String> {
                orderItems.get(0).blng__LegalEntityReference__c
            });

        } catch (Exception eek) {
            System.debug(LoggingLevel.ERROR, 'RemoteTaxOrderProductServiceTest exception: ' + eek.getMessage());
        }
        Test.stopTest();
    }

    static testMethod void testCalculateTaxResponseString2() {
        Map<String, SObject> sbObjectMap = TestUtilities.createToOrderStack(false);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Contact contact = (Contact) sbObjectMap.get(TestUtilities.CONTACT);
        Product2 product = (Product2) sbObjectMap.get(TestUtilities.PRODUCT);
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);
        Order order = (Order) sbObjectMap.get(TestUtilities.ORDER);
        OrderItem orderItem = (OrderItem) sbObjectMap.get(TestUtilities.ORDER_ITEM);
        blng__LegalEntity__c legalEntity = (blng__LegalEntity__c) sbObjectMap.get(TestUtilities.LEGAL_ENTITY);
        List<OrderItem> orderItems = new List<OrderItem> {orderItem};
        System.assertEquals(opportunity.Id, opportunity.id,'opportunity not created');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(200, responseString2));
        RemoteTaxOrderProductDatabaseMockImpl mockDatabase = new RemoteTaxOrderProductDatabaseMockImpl();
        mockDatabase.returnQueryOrderItemByLegalEntityReference.add(orderItem);
        Map<Id, Contact> contactsByOrderIds = new Map<Id, Contact>();
        contactsByOrderIds.put(order.Id, contact);
        mockDatabase.returnContactsByOrderIds = contactsByOrderIds;
        RemoteTaxOrderProductService rtOrderItemService = new RemoteTaxOrderProductService(mockDatabase);
        Map<Id, blng.TaxResults> taxResults;
        try {
            taxResults = rtOrderItemService.getTax(new List<String> {
                orderItems.get(0).blng__LegalEntityReference__c
            });

        } catch (Exception eek) {
            System.debug(LoggingLevel.ERROR, 'RemoteTaxOrderProductServiceTest exception: ' + eek.getMessage());
        }
        Test.stopTest();
    }

    static testMethod void testPostTaxCancelTax() {
        RemoteTaxOrderProductDatabaseMockImpl mockDatabase = new RemoteTaxOrderProductDatabaseMockImpl();
        RemoteTaxOrderProductService rtOrderItemService = new RemoteTaxOrderProductService(mockDatabase);
        rtOrderItemService.postTax(new List<String> {'adeinind'});
        rtOrderItemService.cancelTax(new List<String> {'adeinind'});
        Account acc  = new account(name = 'Test');
        System.assertEquals('Test', acc.Name, 'Account Not Created');
    }

    static String responseString = '{' +
                                    '  \"Header\": {' +
                                    '    \"Systems\": {' +
                                    '      \"CallingApplication\": \"SFDC-GE\",' +
                                    '      \"MessageDate\": \"2017-04-04\",' +
                                    '      \"MessageStatus\": \"OK\",' +
                                    '      \"MessageStatusText\": \"\"' +
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
                                    '            \"Price\": 1032,' +
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

    static String responseStringError = '{' +
                                          '  \"Header\": {' +
                                          '    \"Systems\": {' +
                                          '      \"CallingApplication\": \"SFDC-GE\",' +
                                          '      \"MessageDate\": \"2017-04-04\",' +
                                          '      \"MessageStatus\": \"ERROR\",' +
                                          '      \"MessageStatusText\": \"\"' +
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
                                          '  },' +
                                          ' \"Messages\": [ ' +
                                          ' {  ' +
                                          ' \"MessageReference\": \"bangash.m@girikon.com\",  ' +
                                          ' \"MessageSeverity\": \"1\", ' +
                                          ' \"MessageType\": \"Error\", ' +
                                          ' \"MessageID\": \"99\",  ' +
                                          ' \"MessageText\": \"Error \'EXCEPTION\': \'INVALID_MATERIAL\'.\" ' +
                                          ' } ' +
                                          ' ] ' +
                                          '}';

    static String responseString2 = '{\"Header\": {\"Systems\": {\"CallingApplication\": \"SFDC-GE\",\"MessageDate\":\"2017-08-28\",\"MessageStatus\": \"OK\",\"MessageStatusText\": null}},\"Content\": {\"Transaction\": {\"MetaData\": {\"Customer\": {\"CustomerEmail\":\"bangash.m@girikon.com\"},\"AddressGroup\": {\"BillTo\": {\"PersonName\": {\"Prefix\": null,\"FirstNames\": \"US  Invoice\",\"LastName\":\"Contact\"},\"Address\": {\"Organisation\": null,\"Department\": null,\"AddressLine1\": \"PO Box 800\",\"AddressLine2\": null,\"City\": \"Oxford\",\"State\":null,\"PostalCode\": \"OX5 IDX\",\"Country\": \"UK\",\"PhoneNumber\": null,\"PhoneExtension\": null,\"FaxNumber\": null}},\"ShipTo\": {\"PersonName\": {\"Prefix\":null,\"FirstNames\": \"US  Invoice\",\"LastName\": \"Contact\"},\"Address\": {\"Organisation\": null,\"Department\": null,\"AddressLine1\": \"PO Box 800\",\"AddressLine2\": null,\"City\": \"Oxford\",\"State\": null,\"PostalCode\": \"OX5 IDX\",\"Country\": \"UK\",\"PhoneNumber\": null,\"PhoneExtension\": null,\"FaxNumber\":null}}},\"Currency\": \"EUR\",\"TaxLabel\": \"TAX\"},\"CartItems\": [{\"CartItem\": {\"Quantity\": 100,\"Price\": 10,\"Tax\": 250,\"TaxRates\": [{"TaxRate": 500,"TaxAmount": 10000},{"TaxRate": -500,"TaxAmount": -10000}],\"ItemData\": {\"ProductCode\": \"UKCOMI-TOCEU2018\"}}},{\"CartItem\": {\"Quantity\": 9000,\"Price\": 2767500,\"Tax\": 553500,\"TaxRates\": [{"TaxRate": 500,"TaxAmount": 0},{"TaxRate": -500,"TaxAmount": 0}],\"ItemData\": {\"ProductCode\": \"SPO1LE-TOCEU2018\"}}},{\"CartItem\": {\"Quantity\": 100,\"Price\":10000,\"Tax\": 1000,\"TaxRates\": [{"TaxRate": 500,"TaxAmount": 356400},{"TaxRate": -500,"TaxAmount": -356400}],\"ItemData\": {\"ProductCode\":\"UKCOMI-TOCEU2018\"}}},{\"CartItem\": {\"Quantity\": 100,\"Price\": 1250,\"Tax\": 250,\"TaxRates\": [{"TaxRate": 500,"TaxAmount": 1375},{"TaxRate": -500,"TaxAmount": -1375}],\"ItemData\": {\"ProductCode\":\"LUNCHP-TOCEU2018\"}}}]}},\"Messages\": [{\"MessageReference\": \"bangash.m@girikon.com\",\"MessageSeverity\": \"5\",\"MessageType\": \"Success\",\"MessageID\": \"0",\"MessageText\": null}]}';
    static String responseString3 = '{\"Header\": {\"Systems\": {\"CallingApplication\": \"SFDC-GE\",\"MessageDate\":\"2017-08-28\",\"MessageStatus\": \"OK\",\"MessageStatusText\": null}},\"Content\": {\"Transaction\": {\"MetaData\": {\"Customer\": {\"CustomerEmail\":\"bangash.m@girikon.com\"},\"AddressGroup\": {\"BillTo\": {\"PersonName\": {\"Prefix\": null,\"FirstNames\": \"US  Invoice\",\"LastName\":\"Contact\"},\"Address\": {\"Organisation\": null,\"Department\": null,\"AddressLine1\": \"PO Box 800\",\"AddressLine2\": null,\"City\": \"Oxford\",\"State\":null,\"PostalCode\": \"OX5 IDX\",\"Country\": \"UK\",\"PhoneNumber\": null,\"PhoneExtension\": null,\"FaxNumber\": null}},\"ShipTo\": {\"PersonName\": {\"Prefix\":null,\"FirstNames\": \"US  Invoice\",\"LastName\": \"Contact\"},\"Address\": {\"Organisation\": null,\"Department\": null,\"AddressLine1\": \"PO Box 800\",\"AddressLine2\": null,\"City\": \"Oxford\",\"State\": null,\"PostalCode\": \"OX5 IDX\",\"Country\": \"UK\",\"PhoneNumber\": null,\"PhoneExtension\": null,\"FaxNumber\":null}}},\"Currency\": \"EUR\",\"TaxLabel\": \"TAX\"},\"CartItems\": [{\"CartItem\": {\"Quantity\": 100,\"Price\": 10,\"Tax\": 250,\"TaxRates\": [{"TaxRate": 500,"TaxAmount": 10000}],\"ItemData\": {\"ProductCode\": \"UKCOMI-TOCEU2018\"}}},{\"CartItem\": {\"Quantity\": 9000,\"Price\": 2767500,\"Tax\": 553500,\"TaxRates\": [{"TaxRate": 500,"TaxAmount": 0}],\"ItemData\": {\"ProductCode\": \"SPO1LE-TOCEU2018\"}}},{\"CartItem\": {\"Quantity\": 100,\"Price\":10000,\"Tax\": 1000,\"TaxRates\": [{"TaxRate": 500,"TaxAmount": 356400}],\"ItemData\": {\"ProductCode\":\"UKCOMI-TOCEU2018\"}}},{\"CartItem\": {\"Quantity\": 100,\"Price\": 1250,\"Tax\": 250,\"TaxRates\": [{"TaxRate": 500,"TaxAmount": 1375}],\"ItemData\": {\"ProductCode\":\"LUNCHP-TOCEU2018\"}}}]}},\"Messages\": [{\"MessageReference\": \"bangash.m@girikon.com\",\"MessageSeverity\": \"5\",\"MessageType\": \"Success\",\"MessageID\": \"0",\"MessageText\": null}]}';
    static String responseString4 = '{\"Header\": {\"Systems\": {\"CallingApplication\": \"SFDC-GE\",\"MessageDate\":\"2017-08-28\",\"MessageStatus\": \"OK\",\"MessageStatusText\": null}},\"Content\": {\"Transaction\": {\"MetaData\": {\"Customer\": {\"CustomerEmail\":\"bangash.m@girikon.com\"},\"AddressGroup\": {\"BillTo\": {\"PersonName\": {\"Prefix\": null,\"FirstNames\": \"US  Invoice\",\"LastName\":\"Contact\"},\"Address\": {\"Organisation\": null,\"Department\": null,\"AddressLine1\": \"PO Box 800\",\"AddressLine2\": null,\"City\": \"Oxford\",\"State\":null,\"PostalCode\": \"OX5 IDX\",\"Country\": \"UK\",\"PhoneNumber\": null,\"PhoneExtension\": null,\"FaxNumber\": null}},\"ShipTo\": {\"PersonName\": {\"Prefix\":null,\"FirstNames\": \"US  Invoice\",\"LastName\": \"Contact\"},\"Address\": {\"Organisation\": null,\"Department\": null,\"AddressLine1\": \"PO Box 800\",\"AddressLine2\": null,\"City\": \"Oxford\",\"State\": null,\"PostalCode\": \"OX5 IDX\",\"Country\": \"UK\",\"PhoneNumber\": null,\"PhoneExtension\": null,\"FaxNumber\":null}}},\"Currency\": \"EUR\",\"TaxLabel\": \"TAX\"},\"CartItems\": [{\"CartItem\": {\"Quantity\": 100,\"Price\": 10,\"Tax\": 250,\"TaxRates\": [{"TaxRate": 500,"TaxAmount": 10000},{"TaxRate": 25,"TaxAmount": -10000}],\"ItemData\": {\"ProductCode\": \"UKCOMI-TOCEU2018\"}}},{\"CartItem\": {\"Quantity\": 9000,\"Price\": 2767500,\"Tax\": 553500,\"TaxRates\": [{"TaxRate": 500,"TaxAmount": 0},{"TaxRate": 25,"TaxAmount": 0}],\"ItemData\": {\"ProductCode\": \"SPO1LE-TOCEU2018\"}}},{\"CartItem\": {\"Quantity\": 100,\"Price\":10000,\"Tax\": 1000,\"TaxRates\": [{"TaxRate": 500,"TaxAmount": 356400},{"TaxRate": 25,"TaxAmount": -356400}],\"ItemData\": {\"ProductCode\":\"UKCOMI-TOCEU2018\"}}},{\"CartItem\": {\"Quantity\": 100,\"Price\": 1250,\"Tax\": 250,\"TaxRates\": [{"TaxRate": 500,"TaxAmount": 1375},{"TaxRate": 25,"TaxAmount": -1375}],\"ItemData\": {\"ProductCode\":\"LUNCHP-TOCEU2018\"}}}]}},\"Messages\": [{\"MessageReference\": \"bangash.m@girikon.com\",\"MessageSeverity\": \"5\",\"MessageType\": \"Success\",\"MessageID\": \"0",\"MessageText\": null}]}';
    static String responseString5 = '{\"Header\": {\"Systems\": {\"CallingApplication\": \"SFDC-GE\",\"MessageDate\":\"2017-08-28\",\"MessageStatus\": \"OK\",\"MessageStatusText\": null}},\"Content\": {\"Transaction\": {\"MetaData\": {\"Customer\": {\"CustomerEmail\":\"bangash.m@girikon.com\"},\"AddressGroup\": {\"BillTo\": {\"PersonName\": {\"Prefix\": null,\"FirstNames\": \"US  Invoice\",\"LastName\":\"Contact\"},\"Address\": {\"Organisation\": null,\"Department\": null,\"AddressLine1\": \"PO Box 800\",\"AddressLine2\": null,\"City\": \"Oxford\",\"State\":null,\"PostalCode\": \"OX5 IDX\",\"Country\": \"UK\",\"PhoneNumber\": null,\"PhoneExtension\": null,\"FaxNumber\": null}},\"ShipTo\": {\"PersonName\": {\"Prefix\":null,\"FirstNames\": \"US  Invoice\",\"LastName\": \"Contact\"},\"Address\": {\"Organisation\": null,\"Department\": null,\"AddressLine1\": \"PO Box 800\",\"AddressLine2\": null,\"City\": \"Oxford\",\"State\": null,\"PostalCode\": \"OX5 IDX\",\"Country\": \"UK\",\"PhoneNumber\": null,\"PhoneExtension\": null,\"FaxNumber\":null}}},\"Currency\": \"EUR\",\"TaxLabel\": \"TAX\"},\"CartItems\": [{\"CartItem\": {\"Quantity\": 100,\"Price\": 10,\"Tax\": 250,\"TaxRates\": [{"TaxRate": 500,"TaxAmount":null}],\"ItemData\": {\"ProductCode\": \"UKCOMI-TOCEU2018\"}}},{\"CartItem\": {\"Quantity\": 9000,\"Price\": 2767500,\"Tax\": 553500,\"TaxRates\": [{"TaxRate": 500,"TaxAmount":null}],\"ItemData\": {\"ProductCode\": \"SPO1LE-TOCEU2018\"}}},{\"CartItem\": {\"Quantity\": 100,\"Price\":10000,\"Tax\": 1000,\"TaxRates\": [{"TaxRate": 500,"TaxAmount":null}],\"ItemData\": {\"ProductCode\":\"UKCOMI-TOCEU2018\"}}},{\"CartItem\": {\"Quantity\": 100,\"Price\": 1250,\"Tax\": 250,\"TaxRates\": [{"TaxRate": 500,"TaxAmount":null}],\"ItemData\": {\"ProductCode\":\"LUNCHP-TOCEU2018\"}}}]}},\"Messages\": [{\"MessageReference\": \"bangash.m@girikon.com\",\"MessageSeverity\": \"5\",\"MessageType\": \"Success\",\"MessageID\": \"0",\"MessageText\": null}]}';


    /**
    * Mock class for the database interface.
    */
    public class RemoteTaxOrderProductDatabaseMockImpl implements  RemoteTaxOrderProductService.RemoteTaxOrderProductServiceDatabaseInterface {
        public List<OrderItem> returnQueryOrderItemByLegalEntityReference = new List<OrderItem>();
        public Map<Id, Contact> returnContactsByOrderIds = new Map<Id, Contact>();

        public List<OrderItem> queryOrderItemsByLegalEntityReference(List<String> legalEntityReferences) {
            return returnQueryOrderItemByLegalEntityReference;
        }

        public Map<Id, Contact> queryBillingContactsByIds(List<Id> orderIds) {
            return returnContactsByOrderIds;
        }

        public List<Account_Legal_Entity__c> queryAccountLegalEntitiesByAccountIdAndLegalEntityId(Id accountId, Set<Id> legalEntitySet) {
            return new List<Account_Legal_Entity__c>();
        }
    }
}