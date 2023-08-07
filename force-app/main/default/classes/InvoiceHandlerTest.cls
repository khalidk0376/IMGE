/**
 * Test class for InvoiceHandler
 * @description.....
 Modified By: [Aishwarya 12 Aug 2020 BK-3751]
 */

@IsTest
private class InvoiceHandlerTest {

   @testSetup
    public static void setupData() {
        TestUtilities.createCSIntegrationSettings();
        TestUtilities.createCSBatchSettings();
        TestUtilities.createBillingPrefix();
        TestUtilities.createBillingConfigs();
        Application_Bypass__c oAB = new Application_Bypass__c(SetupOwnerId=UserInfo.getOrganizationId(), Bypass_Validation_Rules__c = True);
        Insert oAB;
        System.assertEquals(oAB.SetupOwnerId, UserInfo.getOrganizationId(), 'Id must be equals'); 
    }

    static testMethod void testApplyPaymentScheduleToInvoice5050() {
        Map<String, SObject> sbObjectMap = TestUtilities.createBillingBackgroundStack(false);
        Brand__c brand = new Brand__c(Name = 'World Of Concrete', Business_Unit__c = 'Life Science');
        Insert brand;
        Event_Series__c eventseries = new Event_Series__c(Name = 'World Of Concrete', Brand__c = brand.Id , CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'WOC', Status__c = 'Active');
        Insert eventseries;
        Event_Edition__c eventEdition = new Event_Edition__c(Name = 'World of Concrete 2017',Cutoff_Date_1__c = system.today(),Payment_Schedule__c = '50-50', Booth_Rent_Stage__c = 'On Payment', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Barter Shell Scheme', Start_Date__c = Date.today(), Part_of_Series__c = eventseries.id,Event_Edition_Status__c = 'Confirmed',No_Billing__c = false);
        Insert eventEdition;
        System.assertEquals(eventEdition.Name, 'World of Concrete 2017', 'The value should be match');
        Account account = TestUtilities.createAccount(true);
        Contact contact = TestUtilities.createContact(account, true);
        blng__LegalEntity__c legalEntity = TestUtilities.createLegalEntity(true);
        blng__BillingRule__c billingRule = TestUtilities.createBillingRule(true);
        blng__TaxRule__c taxRule = TestUtilities.createTaxRule(true);
        blng__RevenueRecognitionRule__c revRecRule = TestUtilities.createRevRecRuleRule(true);
        Product2 product = new Product2();

        product.Name = 'Test Product';
        product.IsActive = true;
        product.ProductCode = 'CL01';
        product.Description = 'Product of Clip Licensing, used to quote for In Library videos';
        product.SBQQ__OptionSelectionMethod__c = 'Click';
        product.SBQQ__ConfigurationType__c = null;
        product.SBQQ__QuantityEditable__c = true;
        product.SBQQ__SubscriptionBase__c = 'List';
        product.SBQQ__Taxable__c = false;
        product.SBQQ__BlockPricingField__c = 'Quantity';
        product.SBQQ__Component__c = false;
        product.SBQQ__DefaultQuantity__c = 1;
        product.SBQQ__ExcludeFromOpportunity__c = false;
        product.SBQQ__PriceEditable__c = true;
        product.SBQQ__PricingMethod__c = 'List';
        product.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        product.SBQQ__SubscriptionType__c = 'Renewable';
        product.SBQQ__SubscriptionTerm__c = 12;
        product.SBQQ__ChargeType__c = 'One-Time';
       // product.SBQQ__BillingType__c = 'Advance';
       // product.SBQQ__BillingFrequency__c = 'Monthly';
        product.validated_in_sap__c = true;
        if (billingRule.Id != null) {
            product.blng__BillingRule__c = billingRule.Id;
        }
        if (taxRule.Id != null) {
            product.blng__TaxRule__c = taxRule.Id;
        }
        if (revRecRule.Id != null) {
            product.blng__RevenueRecognitionRule__c = revRecRule.Id;
        }
        insert product;
        Pricebook2 priceBook = TestUtilities.createPricebook(true);
        PricebookEntry pbEntry = TestUtilities.createPriceBookEntry(product, priceBook, true);
        Opportunity opportunity = TestUtilities.createOpportunity(account, contact, eventEdition, pricebook, true);
        blng__FinanceBook__c financeBook = TestUtilities.createFinanceBookRevenue(true);
        SBQQ__Quote__c quote = TestUtilities.createQuote(account, opportunity, pricebook, true);
        SBQQ__QuoteLine__c quoteLine = TestUtilities.createQuoteLine(product, quote, true);
        
        Test.startTest();

        Order order = new Order();

        order.OpportunityId = opportunity.Id;
        order.Opportunity = opportunity;
        order.AccountId = account.Id;
        order.Account = account;
        order.EffectiveDate = Date.today();
        order.Status = 'Draft';
        order.Pricebook2Id = priceBook.id;
        insert order;
        system.debug('order :: ' + order);
        OrderItem orderItem = new OrderItem();

        orderItem.OrderId = order.Id;
        orderItem.Order = order;
        orderItem.Product2Id = product.Id;
        orderItem.Product2 = product;
        orderItem.SBQQ__QuoteLine__c = quoteLine.Id;
        orderItem.SBQQ__QuoteLine__r = quoteLine;
        orderItem.UnitPrice = 10;
        orderItem.Quantity = 1;
        orderItem.blng__BilledAmountwithouttax__c = 10;
        orderItem.SBQQ__TotalAmount__c = 10;
        orderItem.blng__LegalEntity__c = legalEntity.Id;
        orderItem.blng__LegalEntity__r = legalEntity;
        orderItem.blng__BillingRule__c = billingRule.Id;
        orderItem.blng__BillingRule__r = billingRule;
        orderItem.blng__RevenueRecognitionRule__c = revRecRule.Id;
        orderItem.blng__RevenueRecognitionRule__r = revRecRule;
        orderItem.SBQQ__ChargeType__c = product.SBQQ__ChargeType__c;
        orderItem.blng__TaxRule__c = taxRule.Id;
        orderItem.blng__TaxRule__r = taxRule;
        orderItem.Actual_Tax__c = 2;
        orderItem.blng__FinanceBookAccounting__c = financeBook.Id;
        orderItem.blng__FinanceBookAccounting__r = financeBook;
        orderItem.PricebookEntryId = pbEntry.Id;
        insert orderItem;
        system.debug('orderItem :: ' + orderItem);
        
        List<OrderItem> orderItems = new List<OrderItem>();
        orderItems.add(orderItem);
        
        blng__Invoice__c invoice = TestUtilities.createInvoice(account, order, true, 'AAADEDEDDE');
        
		blng__InvoiceLine__c invoiceLine = new blng__InvoiceLine__c();

        invoiceLine.Name = 'Branded Content';
        invoiceLine.CurrencyIsoCode = 'USD';
        invoiceLine.blng__BillingFinanceBook__c = orderItem.blng__FinanceBookAccounting__c;
        invoiceLine.blng__BillingRule__c = orderItem.blng__BillingRule__c;
        invoiceLine.blng__BillingTreatment__c = orderItem.blng__BillingTreatment__c;
        invoiceLine.blng__CalculatedQuantity__c = 1;
        invoiceLine.blng__ChargeDate__c = Date.today();
        invoiceLine.blng__ChargeType__c = 'One-Time';
        invoiceLine.blng__EndDate__c = Date.today().addMonths(1);
        invoiceLine.blng__InvoiceLineState__c = 'Regular';
        invoiceLine.blng__InvoiceLineStatus__c = 'Draft';
        invoiceLine.blng__Invoice__c = invoice.Id;
        invoiceLine.blng__Invoice__r = invoice;
        invoiceLine.blng__LegalEntityReference__c = orderItem.blng__LegalEntityReference__c;
        invoiceLine.blng__NegativeLineConversion__c = 0;
        invoiceLine.blng__OrderProduct__c = orderItem.Id;
        invoiceLine.blng__OrderProduct__r = orderItem;
        invoiceLine.blng__Product__c = product.Id;
        invoiceLine.blng__Product__r = product;
        invoiceLine.blng__Quantity__c = 1;
        invoiceLine.blng__StartDate__c = Date.today();
        invoiceLine.blng__Subtotal__c = 10.00;
        invoiceLine.blng__TaxErrorMessage__c = 'This line is not taxable';
        invoiceLine.blng__TaxRule__c = orderItem.blng__TaxRule__c;
        invoiceLine.blng__TaxStatus__c = 'Completed';
        //invoiceLine.blng__TaxTreatment__c = 'a2g7A000000DKFLQA4';
        invoiceLine.blng__TotalAmount__c = 10.0;
        invoiceLine.blng__UniqueId__c = 'AAADEDEDDE';
        invoiceLine.blng__UnitPrice__c = 10.0;
        invoiceLine.SAP_Order_ID__c = 'SAPID1';
        invoiceLine.SAPBillingDocumentNumber__c = 'SAPBD1';
        insert invoiceLine;
        
        List<blng__Invoice__c> invoiceList = new List<blng__Invoice__c>();
        invoiceList.add(invoice);
        List<Id> invoiceIdlist = new List<Id>();
        invoiceIdlist.add(invoice.id);
        list<blng__InvoiceLine__c > InvoiceLinec = new List<blng__InvoiceLine__c >();
        InvoiceLinec.add(invoiceLine);
        
        InvoiceHandler.updateFieldsOnInvoice(invoiceList);
        blng__Invoice__c invoices = [select id,ShowUKEquivalent__c from blng__Invoice__c];
        system.debug('invoices:::'+invoices);
        System.assertEquals(invoices.ShowUKEquivalent__c, false, 'The value should be match');
        InvoiceHandler.applyPaymentScheduleToInvoice(invoiceIdlist,InvoiceLinec);
        Test.stopTest();
    }
    
    static testMethod void testApplyPaymentScheduleToInvoice5050OrderNull() {
        Map<String, SObject> sbObjectMap = TestUtilities.createBillingBackgroundStack(false);
        Brand__c brand = new Brand__c(Name = 'World Of Concrete', Business_Unit__c = 'Life Science');
        Insert brand;
        Event_Series__c eventseries = new Event_Series__c(Name = 'World Of Concrete', Brand__c = brand.Id , CurrencyISOCode = 'USD', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'WOC', Status__c = 'Active');
        Insert eventseries;
        Event_Edition__c eventEdition = new Event_Edition__c(Name = 'World of Concrete 2017', Booth_Rent_Stage__c = 'On Payment', Approval_Service_Now_ID__c = '123', CurrencyIsoCode = 'USD', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Barter Shell Scheme', Start_Date__c = Date.today(), Part_of_Series__c = eventseries.id,Event_Edition_Status__c = 'Confirmed',No_Billing__c = false);
        Insert eventEdition;
        System.assertEquals(eventEdition.Name, 'World of Concrete 2017', 'The value should be match');
        Account account = TestUtilities.createAccount(true);
        Contact contact = TestUtilities.createContact(account, true);
        blng__LegalEntity__c legalEntity = TestUtilities.createLegalEntity(true);
        blng__BillingRule__c billingRule = TestUtilities.createBillingRule(true);
        blng__TaxRule__c taxRule = TestUtilities.createTaxRule(true);
        blng__RevenueRecognitionRule__c revRecRule = TestUtilities.createRevRecRuleRule(true);
        
        Product2 product = new Product2();

        product.Name = 'Test Product';
        product.IsActive = true;
        product.ProductCode = 'CL01';
        product.Description = 'Product of Clip Licensing, used to quote for In Library videos';
        product.SBQQ__OptionSelectionMethod__c = 'Click';
        product.SBQQ__ConfigurationType__c = null;
        product.SBQQ__QuantityEditable__c = true;
        product.SBQQ__SubscriptionBase__c = 'List';
        product.SBQQ__Taxable__c = false;
        product.SBQQ__BlockPricingField__c = 'Quantity';
        product.SBQQ__Component__c = false;
        product.SBQQ__DefaultQuantity__c = 1;
        product.SBQQ__ExcludeFromOpportunity__c = false;
        product.SBQQ__PriceEditable__c = true;
        product.SBQQ__PricingMethod__c = 'List';
        product.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        product.SBQQ__SubscriptionType__c = 'Renewable';
        product.SBQQ__SubscriptionTerm__c = 12;
        product.SBQQ__ChargeType__c = 'One-Time';
     
        product.validated_in_sap__c = true;
        if (billingRule.Id != null) {
            product.blng__BillingRule__c = billingRule.Id;
        }
        if (taxRule.Id != null) {
            product.blng__TaxRule__c = taxRule.Id;
        }
        if (revRecRule.Id != null) {
            product.blng__RevenueRecognitionRule__c = revRecRule.Id;
        }
        insert product;
        system.debug('product===>' + product);
        Pricebook2 priceBook = TestUtilities.createPricebook(true);
        PricebookEntry pbEntry = TestUtilities.createPriceBookEntry(product, priceBook, true);
        Opportunity opportunity = TestUtilities.createOpportunity(account, contact, eventEdition, pricebook, true);
        blng__FinanceBook__c financeBook = TestUtilities.createFinanceBookRevenue(true);
        SBQQ__Quote__c quote = TestUtilities.createQuote(account, opportunity, pricebook, true);
        SBQQ__QuoteLine__c quoteLine = TestUtilities.createQuoteLine(product, quote, true);
	    Test.startTest();
        Order order = new Order();

        order.OpportunityId = opportunity.Id;
        order.Opportunity = opportunity;
        order.AccountId = account.Id;
        order.Account = account;
        order.EffectiveDate = Date.today();
        order.Status = 'Draft';
        order.Pricebook2Id = priceBook.id;
        insert order;
        system.debug('order :: ' + order);

        OrderItem orderItem = new OrderItem();

        orderItem.OrderId = order.Id;
        orderItem.Order = order;
        orderItem.Product2Id = product.Id;
        orderItem.Product2 = product;
        orderItem.SBQQ__QuoteLine__c = quoteLine.Id;
        orderItem.SBQQ__QuoteLine__r = quoteLine;
        orderItem.UnitPrice = 10;
        orderItem.Quantity = 1;
        orderItem.blng__BilledAmountwithouttax__c = 10;
        orderItem.SBQQ__TotalAmount__c = 10;
        orderItem.blng__LegalEntity__c = legalEntity.Id;
        orderItem.blng__LegalEntity__r = legalEntity;
        orderItem.blng__BillingRule__c = billingRule.Id;
        orderItem.blng__BillingRule__r = billingRule;
        orderItem.blng__RevenueRecognitionRule__c = revRecRule.Id;
        orderItem.blng__RevenueRecognitionRule__r = revRecRule;
        orderItem.SBQQ__ChargeType__c = product.SBQQ__ChargeType__c;
        orderItem.blng__TaxRule__c = taxRule.Id;
        orderItem.blng__TaxRule__r = taxRule;
        orderItem.Actual_Tax__c = 2;
        orderItem.blng__FinanceBookAccounting__c = financeBook.Id;
        orderItem.blng__FinanceBookAccounting__r = financeBook;
        orderItem.PricebookEntryId = pbEntry.Id;
        insert orderItem;
        system.debug('orderItem :: ' + orderItem);
        
        List<OrderItem> orderItems = new List<OrderItem>();
        orderItems.add(orderItem);

      
        blng__Invoice__c invoice = TestUtilities.createInvoice(account, order, true, 'AAADEDEDDE');
        
        blng__InvoiceLine__c invoiceLine = new blng__InvoiceLine__c();

        invoiceLine.Name = 'Branded Content';
        invoiceLine.CurrencyIsoCode = 'USD';
        invoiceLine.blng__BillingFinanceBook__c = orderItem.blng__FinanceBookAccounting__c;
        invoiceLine.blng__BillingRule__c = orderItem.blng__BillingRule__c;
        invoiceLine.blng__BillingTreatment__c = orderItem.blng__BillingTreatment__c;
        invoiceLine.blng__CalculatedQuantity__c = 1;
        invoiceLine.blng__ChargeDate__c = Date.today();
        invoiceLine.blng__ChargeType__c = 'One-Time';
        invoiceLine.blng__EndDate__c = Date.today().addMonths(1);
        invoiceLine.blng__InvoiceLineState__c = 'Regular';
        invoiceLine.blng__InvoiceLineStatus__c = 'Draft';
        invoiceLine.blng__Invoice__c = invoice.Id;
        invoiceLine.blng__Invoice__r = invoice;
        invoiceLine.blng__LegalEntityReference__c = orderItem.blng__LegalEntityReference__c;
        invoiceLine.blng__NegativeLineConversion__c = 0;
        invoiceLine.blng__OrderProduct__c = orderItem.Id;
        invoiceLine.blng__OrderProduct__r = orderItem;
        invoiceLine.blng__Product__c = product.Id;
        invoiceLine.blng__Product__r = product;
        invoiceLine.blng__Quantity__c = 1;
        invoiceLine.blng__StartDate__c = Date.today();
        invoiceLine.blng__Subtotal__c = 10.00;
        invoiceLine.blng__TaxErrorMessage__c = 'This line is not taxable';
        invoiceLine.blng__TaxRule__c = orderItem.blng__TaxRule__c;
        invoiceLine.blng__TaxStatus__c = 'Completed';
        //invoiceLine.blng__TaxTreatment__c = 'a2g7A000000DKFLQA4';
        invoiceLine.blng__TotalAmount__c = 10.0;
        invoiceLine.blng__UniqueId__c = 'AAADEDEDDE';
        invoiceLine.blng__UnitPrice__c = 10.0;
        invoiceLine.SAP_Order_ID__c = 'SAPID1';
        invoiceLine.SAPBillingDocumentNumber__c = 'SAPBD1';
        insert invoiceLine;
        
        List<blng__Invoice__c> invoiceList = new List<blng__Invoice__c>();
        invoiceList.add(invoice);
        List<Id> invoiceIdlist = new List<Id>();
        invoiceIdlist.add(invoice.id);
        list<blng__InvoiceLine__c > InvoiceLinec = new List<blng__InvoiceLine__c >();
        InvoiceLinec.add(invoiceLine);
            
        InvoiceHandler.updateFieldsOnInvoice(invoiceList);
        blng__Invoice__c invoices = [select id,ShowUKEquivalent__c from blng__Invoice__c];
        system.debug('invoices:::'+invoices);
        System.assertEquals(invoices.ShowUKEquivalent__c, false, 'The value should be match');
        InvoiceHandler.applyPaymentScheduleToInvoice(invoiceIdlist,InvoiceLinec);
        Test.stopTest();
    }

        
}