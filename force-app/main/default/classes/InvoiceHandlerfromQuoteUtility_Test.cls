/**
* Project:         GAP
* Date:            May 24, 2018
* Created By:      Kumar Gaurav
* Test Class For:  InvoiceHandlerfromQuoteUtility/PopulateLegalEntity_class
* Code Coverage:   78%
* *************************************************************************
* @description:Test class for InvoiceHandlerfromQuoteUtility Apex Class.
* *************************************************************************
* History:Modifed test class for increase code coverage apex class : TaxRefundInvoiceLine_Future
* Ticket No.-BK-14522 Updating API Version
*/
@isTest(seeAlldata = false)
public class InvoiceHandlerfromQuoteUtility_Test {
    
    @testSetup
    /**
* @description Test data setup.
*/
    public static void setupData() {
        Utility.isRebookInProcess = True ;
        
        TestUtilities.createCSIntegrationSettings();
        TestUtilities.createCSBatchSettings();
        TestUtilities.createBillingPrefix();
        TestUtilities.createBillingConfigs();
        
        Application_Bypass__c oAB = new Application_Bypass__c(SetupOwnerId=UserInfo.getOrganizationId(), Bypass_Validation_Rules__c = True);
        Insert oAB ;
        Integration_Service__c oCyberSourceCredential = new Integration_Service__c();
        oCyberSourceCredential.Name= 'Cybersource';
        oCyberSourceCredential.User_Name__c = 'girikon'; 
        oCyberSourceCredential.Password__c = 'tttttttttttttt';
        oCyberSourceCredential.End_Point_Url__c = 'https://paymentservicestest.informa.com';
        Insert oCyberSourceCredential;
        
        blng__LegalEntity__c legalentity = new blng__LegalEntity__c(Name = 'Test LegalEntity' , blng__Active__c = true , Legal_Entity_Code__c = 'AE006');
        insert legalentity;
        
        Event_Series__c oEventseries = new Event_Series__c(Name = 'World Of Concrete', Package_Identifier__c = 'WOC', Event_Edition_Pool__c = 'WOC', Active_VAT_Tax_Alt_Currency__c = True, VAT_Tax_Alt_Currency__c = 'ZAR' , Legal_Entity__c = legalentity.id,Status__c = 'Active');
        insert oEventseries;
        
        Pricebook2 pb = new Pricebook2(Name = 'TestPricebook');
        insert pb;
        
        Event_Edition__c oEvent = new Event_Edition__c(Name = 'World of Concrete 2017',Enable_Invoice_Creation_Using_Batch__c = False, Tab1__c = 'Booth Applications', Tab7__c = 'Billing Information',Approval_Service_Now_ID__c = '123', Event_Code__c = 'KDB,KDB2', Booth_Type__c = 'Island,Corner,Inline,Custom,Peninsula', No_Of_Corner__c = '0,1,2,3,4', Booth_Size__c = '100 SqFt,400 SqFt,900 SqFt,1600 SqFt,2500 SqFt', Booth_Product_Type__c = 'Space Only', Expocad_API_Url__c = 'test.com', Part_of_Series__c = oEventseries.id, Booth_Classes_on_Template__c = 'Temp', Corner_Configuration_Check__c = false, Product_Type_Order__c = 'BoothA;;BoothB', CurrencyIsoCode = 'USD',Payment_Schedule__c='25-25-25-25',Cutoff_Date_1__c=System.today(),Cutoff_Date_2__c=System.today().addDays(30),Cutoff_Date_3__c=System.today().addDays(60));
        oEvent.Event_Price_Book__c = pb.Id;
        oEvent.Event_Edition_code__c = 'Adarsh';
        oEvent.End_Date__c = Date.today();
        OEvent.Activate_Invoice_WF__c = true; 
        oEvent.No_Billing__c = false;
        oEVent.Event_Edition_Status__c ='Confirmed';
        insert oEvent;
        
        Map<String, SObject> sbObjectMap = TestUtilities.createBillingBackgroundStack(true);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Product2 product = (Product2) sbObjectMap.get(TestUtilities.PRODUCT);
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);
        opportunity.Custom_Payment__c = True;
        opportunity.Milestone_1_Delivery_Date__c=System.today();
        opportunity.Milestone_2_Delivery_Date__c=System.today().addDays(30);
        opportunity.Milestone_3_Delivery_Date__c=System.today().addDays(60);
        opportunity.Milestone_4_Delivery_Date__c=System.today().addDays(90);
        opportunity.Milestone_5_Delivery_Date__c=System.today().addDays(120);
        opportunity.Milestone_6_Delivery_Date__c=System.today().addDays(150);
        opportunity.Milestone_7_Delivery_Date__c=System.today().addDays(180);
        opportunity.Milestone_8_Delivery_Date__c=System.today().addDays(210);
        opportunity.Milestone_9_Delivery_Date__c=System.today().addDays(240);
        opportunity.Milestone_10_Delivery_Date__c=System.today().addDays(270);
        opportunity.Milestone_11_Delivery_Date__c=System.today().addDays(300);
        opportunity.Milestone_12_Delivery_Date__c=System.today().addDays(330);
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
        opportunity.SBQQ__Contracted__c = true;
        opportunity.By_Pass_Validation_Rule__c = True;
        update opportunity;
        
        TestUtilities.closeWonOpportunity(opportunity.Id, true);
        Test.startTest();
        SBQQ__Quote__c oQuote = new SBQQ__Quote__c(CurrencyIsoCode = 'USD', SBQQ__Status__c = 'Draft', SBQQ__Type__c = 'Quote', SBQQ__Opportunity2__c = opportunity.Id, SBQQ__Account__c = account.Id, SBQQ__Primary__c = true);
        insert oQuote;
        
        SBQQ__QuoteLine__c oQuoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c = oQuote.Id, SBQQ__Product__c = product.Id, SBQQ__Quantity__c = 2, SBQQ__Number__c = 1, Line_Description__c = 'Test', Booth_Number__c = 'TESTBN3', Booth__c = True);
        insert oQuoteLine ;
        
        Contract oContract = new Contract(AccountId = account.id, Status='Sent', StartDate = Date.today(), ContractTerm = 12, SBQQ__Opportunity__c = opportunity.id, SBQQ__Quote__c = oQuote.Id);
        insert oContract;
        Test.stopTest();
    }
    
    static testMethod void beforeUpdateInvoice() {
        Utility.isRebookInProcess = True ;
        Test.startTest();
        Opportunity oOpportunity = [SELECT ID FROM Opportunity LIMIT 1] ;
        Account account = [SELECT Id FROM Account LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        Order order = TestUtilities.createAutomatedOrderFromOpportunity(oOpportunity);
        List<OrderItem> lstOrders = [SELECT ID, Actual_Tax__c FROM OrderItem WHERE ORDERID =: order.id];
        for(OrderItem oTemp : lstOrders){
            oTemp.Actual_Tax__c = 12 ;
        }
        update lstOrders ;
        
        blng__Invoice__c invoice = TestUtilities.createInvoice(account, order, true, 'AAADEDEDDE');      //Modifying this method for BatchInvoiceUpdateForEmail Batch coverage IN PROGRESS
        //invoice.Invoice_Processed__c = true;
        // invoice.blng__InvoiceStatus__c = 'Posted';
        //invoice.Invoice_Emailed_Date__c = date.today();
        //invoice.EventEditionEndDate__c = Date.today();
        //invoice.Activate_Invoice_WF__c = true;
        //System.debug('oninvoice  :::::  ++' + invoice);
        
        //Invoice_Post_Batch c = new Invoice_Post_Batch();
        //Database.executeBatch(c);
        
        Profile pro = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User usr = new User(Alias = 'standt', Email='testuser3011@informa.com.ge', 
                            EmailEncodingKey='UTF-8', LastName='Testing 123', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = pro.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='testclassuser@informa.com.ge');
        insert usr;
        
        List<OrderItem> orderItems = TestUtilities.queryOrderItemsByOrderId(order.Id);
        Currency_Master__c oCurrency = new Currency_Master__c(LocalCurrency__c = 'USD', ForeignCurrency__c = 'ZAR', ExchangeRate__c = 1.05);
        insert oCurrency;     
        blng__InvoiceLine__c invoiceLine = TestUtilities.createInvoiceLine(invoice, orderItems.get(0), product, true);
        invoiceLine.blng__Subtotal__c=200;
        invoiceLine.blng__TaxAmount__c=15;
        //update invoiceLine;
        
        blng__Invoice__c oInvoice = [SELECT Id, Name, Invoice_Emailed_Date__c ,Invoice_Processed__c,blng__Account__c,Post_Invoice_Immediately__c,blng__ARStatus__c, blng__BillToContact__c, blng__DueDate__c, blng__InvoiceDate__c, blng__Notes__c,blng__Order__c,blng__PaymentBatch__c,invoice_percentage__c, blng__PaymentMethod__c, blng__InvoiceStatus__c,blng__TargetDate__c, blng__TaxErrorMessage__c,blng__TaxStatus__c, blng__UniqueId__c,blng__Order__r.SBQQ__Quote__c,blng__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__c,blng__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.EventEdition__r.Payment_Schedule__c,Schedule_Number__c, CurrencyIsoCode, blng__InvoiceRunCreatedBy__c, blng__Order__r.BillToContactId, Invoice_Heirarchy__c, OpportunityId__c, Enable_Invoice_Creation_Using_Batch__c FROM blng__Invoice__c LIMIT 1];
        
        EmailMessage msgObj = new EmailMessage();
        msgObj.FromName = usr.Id;
        msgObj.RelatedToId = oInvoice.Id;
        msgObj.Subject = 'Test';
        msgObj.TextBody = 'Test Body';
        msgObj.ToAddress = 'test@test.com';
        insert msgObj;        
        //System.assertEquals(oInvoice.Invoice_Heirarchy__c, False);
        System.assertEquals(oInvoice.blng__InvoiceStatus__c , 'Draft','Error No Draft');
        System.assertEquals(oInvoice.OpportunityId__c != NULL , True,'Error');
        System.assertEquals(oInvoice.blng__Order__c  != NULL , True,'Error');
        System.assertEquals(oInvoice.Enable_Invoice_Creation_Using_Batch__c, False,'Error');
        Test.stopTest();
        
        //Map<Id, blng__Invoice__c> mapInvToPass = new Map<Id, blng__Invoice__c>();
        Test.setCreatedDate(oInvoice.Id, Datetime.now().addMinutes(-10));
        //mapInvToPass.put(oInvoice.Id, oInvoice);
        Invoice_Batch_Config__c invConfig = new Invoice_Batch_Config__c( );
        invConfig.batch_size_scope__c    = 1;
        invConfig.invoice_pickup_time__c = 1;
        invConfig.schedule_time__c       = 1;
        insert invConfig;
        
        Invoice_InvoiceLineCreateBatchable oInvoiceLine = new Invoice_InvoiceLineCreateBatchable( );
        Database.executeBatch(oInvoiceLine, 1);
        Datetime dt = Datetime.now();
        String sCRONEXP = '0 '+ dt.minute( ) + ' * ' + dt.day( ) + ' ' + dt.month( ) + ' ? ' + dt.year( );
        System.schedule( 'CreateInvoiceTest1', sCRONEXP, oInvoiceLine );
        BatchInvoiceUpdateForEmailSch sh1 = new BatchInvoiceUpdateForEmailSch();
        String sch = '0 0 23 * * ?'; 
        system.schedule('BatchInvoiceUpdateForEmailSch', sch, sh1);
    }
    static testMethod void beforeUpdateInvoiceElse() {
        Utility.isRebookInProcess = True ;
        Test.startTest();
        Opportunity oOpportunity = [SELECT ID FROM Opportunity LIMIT 1] ;
        Account account = [SELECT Id FROM Account LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        Order order = TestUtilities.createAutomatedOrderFromOpportunity(oOpportunity);
        order.SBQQ__Quote__c=null;
        // update order;
        List<OrderItem> lstOrders = [SELECT ID, Actual_Tax__c FROM OrderItem WHERE ORDERID =: order.id];
        for(OrderItem oTemp : lstOrders){
            oTemp.Actual_Tax__c = 12 ;
        }
        update lstOrders ;
        
        blng__Invoice__c invoice = TestUtilities.createInvoice(account, order, true, 'AAADEDEDDE');
        List<OrderItem> orderItems = TestUtilities.queryOrderItemsByOrderId(order.Id);
        Currency_Master__c oCurrency = new Currency_Master__c(LocalCurrency__c = 'USD', ForeignCurrency__c = 'ZAR', ExchangeRate__c = 1.05);
        insert oCurrency;     
        blng__InvoiceLine__c invoiceLine = TestUtilities.createInvoiceLine(invoice, orderItems.get(0), product, true);
        invoiceLine.blng__Subtotal__c=200;
        invoiceLine.blng__TaxAmount__c=15;
        invoiceLine.blng__TaxStatus__c='Completed';
        //update invoiceLine;
        blng__Invoice__c oInvoice = [SELECT Id, Name, blng__Account__c,Post_Invoice_Immediately__c,blng__ARStatus__c, blng__BillToContact__c, blng__DueDate__c, blng__InvoiceDate__c, blng__Notes__c,blng__Order__c,blng__PaymentBatch__c,invoice_percentage__c, blng__PaymentMethod__c, blng__InvoiceStatus__c,blng__TargetDate__c, blng__TaxErrorMessage__c,blng__TaxStatus__c, blng__UniqueId__c,blng__Order__r.SBQQ__Quote__c,blng__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__c,blng__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.EventEdition__r.Payment_Schedule__c,Schedule_Number__c, CurrencyIsoCode, blng__InvoiceRunCreatedBy__c, blng__Order__r.BillToContactId, Invoice_Heirarchy__c, OpportunityId__c, Enable_Invoice_Creation_Using_Batch__c FROM blng__Invoice__c LIMIT 1];
        
        //System.assertEquals(oInvoice.Invoice_Heirarchy__c, False);
        System.assertEquals(oInvoice.blng__InvoiceStatus__c , 'Draft','Error No Draft');
        System.assertEquals(oInvoice.OpportunityId__c != NULL , True,'Error No Draft');
        System.assertEquals(oInvoice.blng__Order__c  != NULL , True,'Error No Draft');
        System.assertEquals(oInvoice.Enable_Invoice_Creation_Using_Batch__c, False,'Error No Draft');
        Test.stopTest();
        
        //Map<Id, blng__Invoice__c> mapInvToPass = new Map<Id, blng__Invoice__c>();
        Test.setCreatedDate(oInvoice.Id, Datetime.now().addMinutes(-10));
        //mapInvToPass.put(oInvoice.Id, oInvoice);
        Invoice_Batch_Config__c invConfig = new Invoice_Batch_Config__c( );
        invConfig.batch_size_scope__c    = 1;
        invConfig.invoice_pickup_time__c = 1;
        invConfig.schedule_time__c       = 1;
        insert invConfig;
        
        
        Invoice_InvoiceLineCreateBatchable oInvoiceLine = new Invoice_InvoiceLineCreateBatchable( );
        Database.executeBatch(oInvoiceLine, 1);
        Datetime dt = Datetime.now();
        String sCRONEXP = '0 '+ dt.minute( ) + ' * ' + dt.day( ) + ' ' + dt.month( ) + ' ? ' + dt.year( );
        System.schedule( 'CreateInvoiceTest2', sCRONEXP, oInvoiceLine );
    }   
    static testMethod void beforeUpdateInvoiceCustomPayment() {
        Utility.isRebookInProcess = True ;
        Test.startTest();
        Opportunity oOpportunity = [SELECT ID FROM Opportunity LIMIT 1] ;
        oOpportunity.Custom_Payment__c=false;
        update oOpportunity;
        Account account = [SELECT Id FROM Account LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        Order order = TestUtilities.createAutomatedOrderFromOpportunity(oOpportunity);
        List<OrderItem> lstOrders = [SELECT ID, Actual_Tax__c FROM OrderItem WHERE ORDERID =: order.id];
        for(OrderItem oTemp : lstOrders){
            oTemp.Actual_Tax__c = 12 ;
        }
        update lstOrders ;
        
        blng__Invoice__c invoice = TestUtilities.createInvoice(account, order, true, 'AAADEDEDDE');
        List<OrderItem> orderItems = TestUtilities.queryOrderItemsByOrderId(order.Id);
        Currency_Master__c oCurrency = new Currency_Master__c(LocalCurrency__c = 'USD', ForeignCurrency__c = 'ZAR', ExchangeRate__c = 1.05);
        insert oCurrency;     
        blng__InvoiceLine__c invoiceLine = TestUtilities.createInvoiceLine(invoice, orderItems.get(0), product, true);
        invoiceLine.blng__Subtotal__c=200;
        invoiceLine.blng__TaxAmount__c=15;
        update invoiceLine;
        Set<Id> setInvoiceLineIds =new Set<Id>();
        setInvoiceLineIds.add(invoiceLine.Id);
        TaxRefundInvoiceLine_Future.updateTaxRefundInvoiceLineStatus (setInvoiceLineIds);
        Update invoice ;
        blng__Invoice__c oInvoice = [SELECT Id, Name, blng__Account__c,Post_Invoice_Immediately__c,blng__ARStatus__c, blng__BillToContact__c, blng__DueDate__c, blng__InvoiceDate__c, blng__Notes__c,blng__Order__c,blng__PaymentBatch__c,invoice_percentage__c, blng__PaymentMethod__c, blng__InvoiceStatus__c,blng__TargetDate__c, blng__TaxErrorMessage__c,blng__TaxStatus__c, blng__UniqueId__c,blng__Order__r.SBQQ__Quote__c,blng__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__c,blng__Order__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.EventEdition__r.Payment_Schedule__c,Schedule_Number__c, CurrencyIsoCode, blng__InvoiceRunCreatedBy__c, blng__Order__r.BillToContactId, Invoice_Heirarchy__c, OpportunityId__c, Enable_Invoice_Creation_Using_Batch__c FROM blng__Invoice__c LIMIT 1];     
        
        //System.assertEquals(oInvoice.Invoice_Heirarchy__c, False);
        System.assertEquals(oInvoice.blng__InvoiceStatus__c , 'Draft','Error No Draft');
        System.assertEquals(oInvoice.OpportunityId__c != NULL , True,'Error No Draft');
        System.assertEquals(oInvoice.blng__Order__c  != NULL , True,'Error No Draft');
        System.assertEquals(oInvoice.Enable_Invoice_Creation_Using_Batch__c, False,'Error No Draft');
        Test.stopTest();
        
        //Map<Id, blng__Invoice__c> mapInvToPass = new Map<Id, blng__Invoice__c>();
        Test.setCreatedDate(oInvoice.Id, Datetime.now().addMinutes(-10));
        //mapInvToPass.put(oInvoice.Id, oInvoice);
        Invoice_Batch_Config__c invConfig = new Invoice_Batch_Config__c( );
        invConfig.batch_size_scope__c    = 1;
        invConfig.invoice_pickup_time__c = 1;
        invConfig.schedule_time__c       = 1;
        insert invConfig;
        
        Invoice_InvoiceLineCreateBatchable oInvoiceLine = new Invoice_InvoiceLineCreateBatchable( );
        Database.executeBatch(oInvoiceLine, 1);
        Datetime dt = Datetime.now();
        String sCRONEXP = '0 '+ dt.minute( ) + ' * ' + dt.day( ) + ' ' + dt.month( ) + ' ? ' + dt.year( );
        System.schedule( 'CreateInvoiceTest3', sCRONEXP, oInvoiceLine );     
        
    }
    
    static testMethod void cancelInvoice() {
        Utility.isRebookInProcess = True ;
        Test.setMock(HttpCalloutMock.class, new CyberSourceMock());
        Test.startTest();
        Opportunity oOpportunity = [SELECT ID FROM Opportunity LIMIT 1] ;
        Account account = [SELECT Id FROM Account LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        Order order = TestUtilities.createAutomatedOrderFromOpportunity(oOpportunity);
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
        
        oInvoice.blng__InvoiceStatus__c = 'Rebilled';
        oInvoice.Cancellation_Reason__c = 'Test';
        update oInvoice;
        
        PageReference pref = Page.InvoiceCancellation;
        pref.getParameters().put('id', order.Id);
        pref.getParameters().put('pAction', 'cancelOrder');
        Test.setCurrentPage(pref);
        
        InvoiceCancellationCtrl oInvoiceCancellationCtrl = new InvoiceCancellationCtrl();
        oInvoiceCancellationCtrl.sCancelSuccessMsg = 'Not Cancelled';
        oInvoiceCancellationCtrl.cancelInvoice();
        oInvoiceCancellationCtrl.batchProcess();
        oInvoiceCancellationCtrl.redirectToRecord();
        System.assertEquals(account.Id, account.Id,'Error No Draft');
        Test.stopTest();
    }  
}