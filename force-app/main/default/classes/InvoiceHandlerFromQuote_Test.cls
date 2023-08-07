/**
* @Project         GAP
* @Date           May 24, 2018
* @Created By      Abdul Kadir
* @Test Class For  InvoiceHandlerfromQuote
* Code Coverage   93%
* Modified By  Himanshu Jasuja -  BK-3676 //Added all assert statement
* *************************************************************************
* @description :::   Test class for InvoiceHandlerFromQuote Apex Class.
* *************************************************************************
* @History Modified By - Rajesh Kumar - on 30-07-2020 to BK-6532
*/

@isTest(seeAlldata = false)
public class InvoiceHandlerFromQuote_Test {
    
    @testSetup static void setupData() {
        Utility.isRebookInProcess = True ;
        TestUtilities.createCSIntegrationSettings();
        TestUtilities.createCSBatchSettings();
        TestUtilities.createBillingPrefix();
        TestUtilities.createBillingConfigs();        
        //Update By Rajesh Kumar Yadav
        List<Tax_Language__c> taxlist=new List<Tax_Language__c>();
        Tax_Language__c oTaxLanguage = new Tax_Language__c(Name = 'AE006USD' , Language__c = 'Language__c' , Language_2__c = 'TestLanguage_2__c');
        Tax_Language__c oTaxLanguage1 = new Tax_Language__c(Name = 'GB157TR20MAD' , Language__c = 'Language__c' , Language_2__c = 'TestLanguage_2__c');
        Tax_Language__c oTaxLanguage2 = new Tax_Language__c(Name = 'AE006Bank' , Language__c = 'Language__c' , Language_2__c = 'TestLanguage_2__c');
        taxlist.add(oTaxLanguage);
        taxlist.add(oTaxLanguage1);
        taxlist.add(oTaxLanguage2);
        insert taxlist;
        
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
    /**
* @description Here we create coustom data for the testing method two.
*/
    @isTest static void invoicehandlerfromQuoteCoverage() {
        List<blng__Invoice__c> lstInv = new List<blng__Invoice__c>();
        Utility.isRebookInProcess = True ;
        
        //Update By Rajesh Kumar Yadav
        Tax_Language__c oTaxLanguage = new Tax_Language__c(Name = 'AE006USD', Language__c = 'Language__c' , Language_2__c = 'TestLanguage_2__c');
        insert oTaxLanguage;
        System.assertNotEquals(null,oTaxLanguage.Name,'Tax Language Name should not be null');
        
        Opportunity oOpportunity = [SELECT ID FROM Opportunity  LIMIT 1] ;
        system.debug('oOpportunity details' + oOpportunity );
        Account account = [SELECT Id FROM Account LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        Order order = TestUtilities.createAutomatedOrderFromOpportunity(oOpportunity);
        order.SBQQ__Quote__c = NULL;
        order.Status = 'Draft';
        order.StatusCode = 'Activated';
        update order;
        List<OrderItem> lstOrders = [SELECT ID, Actual_Tax__c, SAP_Tax_Code__c, SAP_Tax_Country__c FROM OrderItem WHERE ORDERID = : order.id];
        for (OrderItem oTemp : lstOrders) {
            oTemp.Actual_Tax__c = 12 ;
            oTemp.SAP_Tax_Country__c = 'test';
            oTemp.SAP_Tax_Code__c = 'Test';
            oTemp.SAP_Primary_Tax_Rate__c = '05%';
            oTemp.SAP_Secondary_Tax_Rate__c = '12%';
        }
        update lstOrders ;
        
        blng__Invoice__c invoice = TestUtilities.createInvoice(account, order, true, 'AAADEDEDDE');
        invoice.Alternate_Bank_Address__c=true;
        update invoice;
        List<OrderItem> orderItems = TestUtilities.queryOrderItemsByOrderId(order.Id);
        Currency_Master__c oCurrency = new Currency_Master__c(LocalCurrency__c = 'USD', ForeignCurrency__c = 'ZAR', ExchangeRate__c = 1.05);
        insert oCurrency;
        blng__InvoiceLine__c invoiceLine = TestUtilities.createInvoiceLine(invoice, orderItems.get(0), product, true);
        
        String sDynamicQueryFlds = new Invoice_InvoiceLineCreateBatchable().dynamicQuery('blng__Invoice__c');
        String sQuery = 'SELECT ' + sDynamicQueryFlds + ', blng__Order__r.SBQQ__Quote__c, blng__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__c, blng__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.EventEdition__r.Payment_Schedule__c,blng__Order__r.BillToContactId FROM blng__Invoice__c WHERE ID =\'' + invoice.Id + '\'';
        
        blng__Invoice__c oInvoice = Database.Query(sQuery);
        lstInv.add(oInvoice);
        Map<Id, blng__Invoice__c> mapInvToPass = new Map<Id, blng__Invoice__c>();
        mapInvToPass.put(oInvoice.Id, oInvoice);
        Test.startTest();
        InvoiceHandlerfromQuoteUtility.createInvoice_InvoiceLines(mapInvToPass);
        Tax_Language__c opp = [Select Id, Name, Language__c from Tax_Language__c WHERE Name = 'AE006USD' Limit 1];
        
        //UKEUorROW__c == 'UK' && invoice.CurrencyCode__c != 'GBP' && invoice.TaxRate__c == 20)
        blng__InvoiceLine__c invline = [Select Id, Name, blng__TaxStatus__c from blng__InvoiceLine__c Limit 1];
        invline.blng__TaxStatus__c = 'Queued';
        update invline;
        System.assertEquals('Language__c', opp.Language__c, 'Error');
        blng__Invoice__c invoice22 = TestUtilities.createInvoice(account, order, true, 'AAADEDEDDE');
        TaxLanguageHelper.getLanguageTextForVatFooterForMAD('GB157',20);
        TaxLanguageHelper.getLanguagealternateCreditTransfer('AE006Bank');

        InvoiceHandlerFromQuote.updateFieldsOnInvoice(lstInv);
        Test.stopTest();
        
        InvoiceHandlerFromQuote.InvoiceLineWrapper wrapper = new InvoiceHandlerFromQuote.InvoiceLineWrapper(invoiceLine);
        wrapper.compareTo(wrapper);
        
    }
    
    
    @isTest static void InvoiceLineWrapperTest()
    {
        
        Opportunity oOpportunity = [SELECT ID FROM Opportunity LIMIT 1] ;
        Account account = [SELECT Id FROM Account LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        Order order = TestUtilities.createAutomatedOrderFromOpportunity(oOpportunity);
       // order.SBQQ__Quote__c = NULL;
        order.Status = 'Draft';
        order.StatusCode = 'Activated';
        update order;
        List<blng__Invoice__c> lstInv = new List<blng__Invoice__c>();
        blng__Invoice__c invoice = TestUtilities.createInvoice(account, order, true, 'AAADEDEDDE');
        blng__Invoice__c invoice1 = TestUtilities.createInvoice(account, order, true, 'sssss');
        blng__Invoice__c invoice2 = TestUtilities.createInvoice(account, order, true, 'aaaaa');
        lstInv.add(invoice);
        lstInv.add(invoice1);
        lstInv.add(invoice2);
       
        lstInv.sort();
        
        system.assertEquals('Draft', invoice.blng__InvoiceStatus__c, 'Error Status not match');
        //testWrap.compareTo(testWrap);
    }
}