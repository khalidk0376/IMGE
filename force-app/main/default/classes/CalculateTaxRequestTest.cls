/**
* Test class for CalculateTaxRequest
* Modified By Palla Kishore for the Api version Ticket EMEA-264
*/

@IsTest
private class CalculateTaxRequestTest {
    
    @testSetup
    public static void setupData() {        
        Utility.isRebookInProcess = True ;
        TestUtilities.createCSIntegrationSettings();
        TestUtilities.createCSBatchSettings();
        TestUtilities.createBillingPrefix();
        TestUtilities.createBillingConfigs();        
        //Update By Rajesh Kumar Yadav
        Tax_Language__c oTaxLanguage = new Tax_Language__c(Name = 'AE006USD' , Language__c = 'Language__c' , Language_2__c = 'TestLanguage_2__c');
        insert oTaxLanguage;
        System.assertNotEquals(null,oTaxLanguage.Name,'Tax Language Name should not be null');
        
        Application_Bypass__c oAB = new Application_Bypass__c(SetupOwnerId = UserInfo.getOrganizationId(), Bypass_Validation_Rules__c = True);
        Insert oAB ;
        System.assertNotEquals(null,oAB.SetupOwnerId,'Owner Id should not be null');
        
        Integration_Service__c oCyberSourceCredential = new Integration_Service__c();
        oCyberSourceCredential.Name = 'Cybersource';
        oCyberSourceCredential.User_Name__c = 'girikon';
        oCyberSourceCredential.Password__c = 'tttttttttttttt';
        oCyberSourceCredential.End_Point_Url__c = 'https://paymentservicestest.informa.com';
        Insert oCyberSourceCredential;
        System.assertNotEquals(null,oCyberSourceCredential.Name,'CyberSource Credential Name should not be null');
        
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete',Status__c = 'Active', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'WOC', Active_VAT_Tax_Alt_Currency__c = True, VAT_Tax_Alt_Currency__c = 'ZAR');
        insert oEventseries;
        System.assertNotEquals(null,oEventseries.Name,'Event Series Name should not be null');
        
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Enable_Invoice_Creation_Using_Batch__c = True, Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB', CurrencyIsoCode = 'USD', Start_Date__c = system.today(),Event_Edition_Code__c = 'Akshi_Test ', Event_Edition_Status__c = 'Confirmed',No_Billing__c = false);
        insert oEvent;
        system.debug('oEvent :::' + oEvent);
        System.assertNotEquals(null,oEvent.Name,'Event Edition Name should not be null');
        
        Map<String, SObject> sbObjectMap = TestUtilities.createBillingBackgroundStack(true);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Contact contact = (Contact) sbObjectMap.get(TestUtilities.CONTACT);
        Product2 product = (Product2) sbObjectMap.get(TestUtilities.PRODUCT);
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);
        opportunity.Custom_Payment__c = True;
        opportunity.Milestone_1_Delivery_Date__c = System.today();
        opportunity.Milestone_2_Delivery_Date__c = System.today().addDays(30);
        opportunity.Milestone_3_Delivery_Date__c = System.today().addDays(60);
        opportunity.Milestone_4_Delivery_Date__c = System.today().addDays(90);
        opportunity.Milestone_5_Delivery_Date__c = System.today().addDays(120);
        opportunity.Milestone_6_Delivery_Date__c = System.today().addDays(150);
        opportunity.Milestone_7_Delivery_Date__c = System.today().addDays(180);
        opportunity.Milestone_8_Delivery_Date__c = System.today().addDays(210);
        opportunity.Milestone_9_Delivery_Date__c = System.today().addDays(240);
        opportunity.Milestone_10_Delivery_Date__c = System.today().addDays(270);
        opportunity.Milestone_11_Delivery_Date__c = System.today().addDays(300);
        opportunity.Milestone_12_Delivery_Date__c = System.today().addDays(330);
        opportunity.Milestone_1_Amount__c = 200.00;
        opportunity.Milestone_2_Amount__c = 200.00;
        opportunity.Milestone_3_Amount__c = 200.00;
        opportunity.Milestone_4_Amount__c = 200.00;
        opportunity.Milestone_5_Amount__c = 200.00;
        opportunity.Milestone_6_Amount__c = 200.00;
        opportunity.Milestone_7_Amount__c = 200.00;
        opportunity.Milestone_8_Amount__c = 200.00;
        opportunity.Milestone_9_Amount__c = 200.00;
        opportunity.Milestone_10_Amount__c = 200.00;
        opportunity.Milestone_11_Amount__c = 200.00;
        opportunity.Milestone_12_Amount__c = 200.00;
        opportunity.Milestone_1_Percent__c = 8.2;
        opportunity.Milestone_2_Percent__c = 8.3;
        opportunity.Milestone_3_Percent__c = 8.2;
        opportunity.Milestone_4_Percent__c = 8.2;
        opportunity.Milestone_5_Percent__c = 8.3;
        opportunity.Milestone_6_Percent__c = 8.3;
        opportunity.Milestone_7_Percent__c = 8.2;
        opportunity.Milestone_8_Percent__c = 8.3;
        opportunity.Milestone_9_Percent__c = 8.3;
        opportunity.Milestone_10_Percent__c = 8.2;
        opportunity.Milestone_11_Percent__c = 8.3;
        opportunity.Milestone_12_Percent__c = 8.3;
        
        opportunity.Event_Series__c = oEventseries.id ;
        opportunity.EventEdition__c = oEvent.Id;
        //opportunity.Online_Booth_Capture__c = objOBC.Id;
        opportunity.SBQQ__Contracted__c = false;
        update opportunity;
        opportunity.SBQQ__Contracted__c = True;
        update opportunity;
        
        TestUtilities.closeWonOpportunity(opportunity.Id, True);
        Test.startTest();
        
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = opportunity.Id, SBQQ__Account__c = account.Id, SBQQ__Primary__c = true);
        insert oQuote;
        System.assertNotEquals(null,oQuote.CurrencyIsoCode,'Quote should not be null');
        
        SBQQ__QuoteLine__c oQuoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.Id, SBQQ__Product__c = product.Id,Standard_Unit__c = 'M2', SBQQ__Quantity__c = 2, SBQQ__Number__c = 1, Line_Description__c = 'Test', Booth_Number__c = 'TESTBN3', Booth__c = True);
        insert oQuoteLine ;
        System.assertNotEquals(null,oQuoteLine.SBQQ__Quote__c,'Quote Line should not be null');
        
        Contract oContract = new Contract(AccountId = account.id, Status = 'Sent', StartDate = Date.today(), ContractTerm = 12, SBQQ__Opportunity__c = opportunity.id, SBQQ__Quote__c = oQuote.Id);
        insert oContract;
        System.assertNotEquals(null,oContract.AccountId,'Contract not be null');
        
        Contract opp = [Select Id, Status from Contract WHERE ID = : oContract.Id];
        System.assertEquals('USD', oQuote.CurrencyIsoCode,'ISO CODE');        
        Test.stopTest();
    }
    
    static testMethod void testParse() {
        String json = '{'+
            '  \"Header\": {'+
            '    \"Systems\": {'+
            '      \"CallingApplication\": \"SFDC-GE\",'+
            '      \"MessageDate\": \"2017-04-04\"'+
            '    }'+
            '  },'+
            '  \"Content\": {'+
            '    \"Transaction\": {'+
            '      \"MetaData\": {'+
            '        \"Customer\": {'+
            '          \"CustomerNumber\": \"BP010101010101\",'+
            '          \"CustomerNumberType\": \"BP\",'+
            '          \"CustomerEmail\": \"mulesoft@informa.com\"'+
            '        },'+
            '        \"AddressGroup\": {'+
            '          \"BillTo\": {'+
            '            \"PersonName\": {'+
            '              \"Prefix\": \"Mr.\",'+
            '              \"FirstNames\": \"Guan\",'+
            '              \"LastName\": \"Carlos\"'+
            '            },'+
            '            \"Address\": {'+
            '              \"Organisation\": \"Informa\",'+
            '              \"Department\": \"Global Support\",'+
            '              \"AddressLine1\": \"Schimmelt 32\",'+
            '              \"AddressLine2\": \"\",'+
            '              \"City\": \"Eindhoven\",'+
            '              \"State\": \"\",'+
            '              \"PostalCode\": \"5611 ZX\",'+
            '              \"Country\": \"NL\",'+
            '              \"PhoneNumber\": \"3161234567890\",'+
            '              \"PhoneExtension\": \"x1234\",'+
            '              \"FaxNumber\": \"3161234567899\"'+
            '            }'+
            '          },'+
            '          \"ShipTo\": {'+
            '            \"PersonName\": {'+
            '              \"Prefix\": \"Mr.\",'+
            '              \"FirstNames\": \"Guan\",'+
            '              \"LastName\": \"Carlos\"'+
            '            },'+
            '            \"Address\": {'+
            '              \"Organisation\": \"Informa\",'+
            '              \"Department\": \"Global Support\",'+
            '              \"AddressLine1\": \"Schimmelt 32\",'+
            '              \"AddressLine2\": \"\",'+
            '              \"City\": \"Eindhoven\",'+
            '              \"State\": \"\",'+
            '              \"PostalCode\": \"5611 ZX\",'+
            '              \"Country\": \"NL\",'+
            '              \"PhoneNumber\": \"3161234567890\",'+
            '              \"PhoneExtension\": \"x1234\",'+
            '              \"FaxNumber\": \"3161234567899\"'+
            '            }'+
            '          }'+
            '        },'+
            '        \"Currency\": \"GBP\"'+
            '      },'+
            '      \"CartItems\": ['+
            '        {'+
            '          \"CartItem\": {'+
            '            \"Quantity\": 1,'+
            '            \"Price\": 5535,'+
            '            \"ItemData\": {'+
            '              \"ProductCode\": \"I12345\"'+
            '            }'+
            '          }'+
            '        }'+
            '      ]'+
            '    }'+
            '  }'+
            '}';
        System.debug('CalculateTaxRequestTest ' + json);
        CalculateTaxRequest obj = CalculateTaxRequest.parse(json);
        System.assert(obj != null,'Tax Request is empty');
        System.assert(obj.Content.Transaction_x != null,'No data in Content_Transaction');
        System.assertEquals('GBP', obj.Content.Transaction_x.MetaData.Currency_x,'No data in Content_Transaction_MetaData_Currency_x');
    }
    
    static testMethod void testCalculateTaxRequestOrderItem() {
        Test.startTest();
        Opportunity oOpportunity = [SELECT ID FROM Opportunity  LIMIT 1] ;
        system.debug('oOpportunity details' + oOpportunity );
        Account account = [SELECT Id FROM Account LIMIT 1];
        Contact contact = [Select id,Email,FirstName,LastName,Account.BillingStreet,Account.Billing_Address_Line_2__c,Account.BillingCity,Account.BillingPostalCode,Account.BillingCountryCode,Account.BillingStateCode from contact Limit 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];        
        
        Order order = TestUtilities.createAutomatedOrderFromOpportunity(oOpportunity);
        order.SBQQ__Quote__c = NULL;
        order.Status = 'Draft';
        order.StatusCode = 'Activated';
        order.BillToContact = contact;
        update order;
        
        List<OrderItem> lstOrders = TestUtilities.queryOrderItemsByOrderId(order.Id);        
        Map<Id, Contact> contactsByIds = new Map<Id, Contact>();
        contactsByIds.put(order.Id, contact);       
        account acc = new account(name = 'Test');
        System.assertEquals('Test', acc.Name,'Invalid AccountName'); 
        CalculateTaxRequest ctRequest = new CalculateTaxRequest(lstOrders, contactsByIds, contactsByIds, '342398234343');
        Test.stopTest();
    }
    
    static testMethod void testCalculateTaxRequestInvoiceLine() {
        
        Test.startTest();
        Opportunity oOpportunity = [SELECT ID FROM Opportunity  LIMIT 1] ;
        system.debug('oOpportunity details' + oOpportunity );
        Account account = [SELECT Id FROM Account LIMIT 1];
        Contact contact = [Select id,Email,FirstName,LastName,Account.BillingCountry,Account.BillingStreet,Account.Billing_Address_Line_2__c,Account.BillingCity,Account.BillingPostalCode,Account.BillingCountryCode,Account.BillingStateCode from contact Limit 1];
        Product2 product = [SELECT Id,ProductCode,Event_Product_Type__c FROM Product2 LIMIT 1];        
        
        Order order = TestUtilities.createAutomatedOrderFromOpportunity(oOpportunity);
        order.SBQQ__Quote__c = NULL;
        order.Status = 'Draft';
        order.StatusCode = 'Activated';
        order.BillToContact = contact;
        update order;
        
        List<OrderItem> lstOrders = TestUtilities.queryOrderItemsByOrderId(order.Id);        
        Map<Id, Contact> contactsByIds = new Map<Id, Contact>();
        contactsByIds.put(order.Id, contact);       
        
        blng__Invoice__c invoice = TestUtilities.createInvoice(account, order, true, 'AAADEDEDDE');
        blng__InvoiceLine__c invoiceLine = TestUtilities.createInvoiceLine(invoice, lstOrders.get(0), product, false);
        
        CalculateTaxRequest ctRequest = new CalculateTaxRequest(new List<blng__InvoiceLine__c> {invoiceLine}, contactsByIds, contactsByIds, '342398234343');
        Test.stopTest();
    }
}