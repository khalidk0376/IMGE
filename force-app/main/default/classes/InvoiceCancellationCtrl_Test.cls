/**
 * Project:         GAP
 * Date:            Aug 17, 2018
 * Test Class For:  InvoiceCancellationCtrl.cls
 * Code Coverage:   97%
 * Created By:      Kumar Gaurav
 * *************************************************************************
 * @description Test class for InvoiceCancellationCtrl Class.
 * *************************************************************************
 * History:
 */

@isTest(seeAlldata = false)
public class InvoiceCancellationCtrl_Test {

    @testSetup
    /**
     * @description Test data setup
     */
    public static void setupData() {
        Utility.isRebookInProcess = True ;

        TestUtilities.createCSIntegrationSettings();
        TestUtilities.createCSBatchSettings();
        TestUtilities.createBillingPrefix();
        TestUtilities.createBillingConfigs();

        Application_Bypass__c oAB = new Application_Bypass__c(SetupOwnerId = UserInfo.getOrganizationId(), Bypass_Validation_Rules__c = True);
        Insert oAB ;
        Integration_Service__c oCyberSourceCredential = new Integration_Service__c();
        oCyberSourceCredential.Name = 'Cybersource';
        oCyberSourceCredential.User_Name__c = 'girikon';
        oCyberSourceCredential.Password__c = 'tttttttttttttt';
        oCyberSourceCredential.End_Point_Url__c = 'https://paymentservicestest.informa.com';
        Insert oCyberSourceCredential;

        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'WOC', Active_VAT_Tax_Alt_Currency__c = True, VAT_Tax_Alt_Currency__c = 'ZAR');
        oEventseries.Status__c = 'Active';
        insert oEventseries;

        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017', Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information', Approval_Service_Now_ID__c = '123', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB', CurrencyIsoCode = 'USD');
        oEvent.Part_of_Series__c = oEventseries.Id;
        oEvent.Event_Edition_Code__c = 'test';
        oEvent.Event_Edition_Status__c = 'Confirmed';
        insert oEvent;
        
        Map<String, SObject> sbObjectMap = TestUtilities.createBillingBackgroundStack(true);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Product2 product = (Product2) sbObjectMap.get(TestUtilities.PRODUCT);
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);
        opportunity.Event_Series__c = oEventseries.id ;
        opportunity.SBQQ__Contracted__c = false;
        update opportunity;
        opportunity.SBQQ__Contracted__c = True;
        update opportunity;

        TestUtilities.closeWonOpportunity(opportunity.Id, True);
        Test.startTest();
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = opportunity.Id, SBQQ__Account__c = account.Id, SBQQ__Primary__c = true);
        insert oQuote;

        SBQQ__QuoteLine__c oQuoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.Id, SBQQ__Product__c = product.Id, SBQQ__Quantity__c = 2, SBQQ__Number__c = 1, Line_Description__c = 'Test', Booth_Number__c = 'TESTBN3', Booth__c = True);
        insert oQuoteLine ;

        Contract oContract = new Contract(AccountId = account.id, Status = 'Sent', StartDate = Date.today(), ContractTerm = 12, SBQQ__Opportunity__c = opportunity.id, SBQQ__Quote__c = oQuote.Id);
        insert oContract;
        Opportunity opp = [Select Id, Name, SBQQ__Contracted__c from Opportunity WHERE ID = : opportunity.Id];
        System.assertEquals(opportunity.Name, opp.Name, 'Error');
        Test.stopTest();
    }

    static testMethod void cancelInvoice() {
        Utility.isRebookInProcess = True ;
        Test.setMock(HttpCalloutMock.class, new CyberSourceMock());
        test.startTest();
        Opportunity oOpportunity = [SELECT ID FROM Opportunity LIMIT 1] ;
        Account account = [SELECT Id FROM Account LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        Order order = TestUtilities.createAutomatedOrderFromOpportunity(oOpportunity);
        test.stopTest();
        List<OrderItem> lstOrders = [SELECT ID, Actual_Tax__c FROM OrderItem WHERE ORDERID = : order.id];
        for (OrderItem oTemp : lstOrders) {
            oTemp.Actual_Tax__c = 12 ;
        }
        update lstOrders ;
        blng__Invoice__c invoice = TestUtilities.createInvoice(account, order, true, 'AAADEDEDDE');
        List<OrderItem> orderItems = TestUtilities.queryOrderItemsByOrderId(order.Id);
        blng__Invoice__c oInvoice = [SELECT Default_Currency__c, blng__Order__r.Opportunity.Event_Series__r.VAT_Tax_Alt_Currency__c FROM blng__Invoice__c WHERE ID = : invoice.Id];
        Currency_Master__c oCurrency = new Currency_Master__c(LocalCurrency__c = oInvoice.Default_Currency__c, ForeignCurrency__c = oInvoice.blng__Order__r.Opportunity.Event_Series__r.VAT_Tax_Alt_Currency__c, ExchangeRate__c = 1.05);
        insert oCurrency;
        blng__InvoiceLine__c invoiceLine = TestUtilities.createInvoiceLine(invoice, orderItems.get(0), product, true);
        invoiceLine.blng__TaxAmount__c = 203 ;
        invoiceLine.blng__TotalAmount__c = 100 ;
        invoiceLine.blng__TaxStatus__c   = 'Completed';
        update invoiceLine;
        oInvoice.Invoice_Heirarchy__c = 'Child Invoice';
        oInvoice.blng__InvoiceStatus__c = 'Posted';
        update oInvoice;
        System.assertEquals('Posted', oInvoice.blng__InvoiceStatus__c,'oInvoice status should be posted');
       
        Id batchProcessId;
        InvoiceCancellationCtrl invCancel = new InvoiceCancellationCtrl( order.id );
        batchProcessId = Database.executeBatch( invCancel, 1 );
        
        AsyncApexJob asynObj = new AsyncApexJob();
       // asynObj.Status = 'Completed';
       // insert asynObj;

        PageReference pref = Page.InvoiceCancellation;
        pref.getParameters().put('id', order.Id);
        pref.getParameters().put('pAction', 'cancelOrder');
        Test.setCurrentPage(pref);
          
        InvoiceCancellationCtrl oInvoiceCancellationCtrl = new InvoiceCancellationCtrl();
        oInvoiceCancellationCtrl.sCancelSuccessMsg = 'Not Cancelled';
        oInvoiceCancellationCtrl.cancelInvoice();
        oInvoiceCancellationCtrl.batchProcess();
        
        oInvoiceCancellationCtrl.redirectToRecord();
       

    }
}