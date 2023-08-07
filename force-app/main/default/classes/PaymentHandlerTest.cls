/**
 * Project:         GAP
 * Date:            26/12/2018
 * Test Class For:  PaymentHandler
 * Code Coverage:
 * Created By:      Margaret Persico
 * *************************************************************************
 * @description     This test class covers "PaymentHandler" class.
 * *************************************************************************
 * History:
 * Ticket No.-BK-14522 Updating API Version
 */

@IsTest
private class PaymentHandlerTest {
    /**
     * [setupData description calling Testutilities class for setup data]
     */

    @testSetup
    public static void setupData() {
        TestUtilities.createBillingPrefix();
        TestUtilities.createBillingConfigs();
    }

    static testMethod void testHandlePaymentAllocation() {

        List<Id> lstInvIds = new List<Id>();
        List<Id> lstInvRunsIds = new List<Id>();
        List<blng__Payment__c> lstPayment = new List<blng__Payment__c>();
        List<Contract> lstContract = new List<Contract>();
        List<blng__PaymentAllocationInvoice__c> lstPaymentAllocation = new List<blng__PaymentAllocationInvoice__c>();
        Set<Id> setRelConIds = new Set<Id>();
        Set<Id> setInvIds = new Set<Id>();
        Set<Id> setPaymentIds = new Set<Id>();
        Set<Id> setAccIds = new Set<Id>();
        List<String> lstInvStatus = new List<String>();
        List<Id> lstOrderIds = new List<Id>();
        Id invoiceRunId = TestUtilities.getFakeId(blng__InvoiceRun__c.getSObjectType());
        lstInvRunsIds.add(invoiceRunId);

        Map<String, SObject> sbObjectMap = TestUtilities.createToInvoiceStack(false);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        setAccIds.add(account.Id);
        Order anOrder = (Order) sbObjectMap.get(TestUtilities.ORDER);
        lstOrderIds.add(anOrder.Id);
        blng__Invoice__c invoice = (blng__Invoice__c) sbObjectMap.get(TestUtilities.INVOICE);
        blng__InvoiceLine__c invoiceLine = (blng__InvoiceLine__c) sbObjectMap.get(TestUtilities.INVOICE_LINE);
        blng__Payment__c payment = TestUtilities.createPayment(account, invoice, false);
        lstPayment.add(payment);
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);
        blng__Invoice__c inv = new blng__Invoice__c();
        inv.blng__Account__c = account.Id;
        inv.CurrencyIsoCode = 'USD';
        inv.Schedule_Number__c = 1;
        inv.blng__Order__c = anOrder.Id;
        inv.blng__InvoiceStatus__c = 'Draft';
        Map<Id, blng__Payment__c> paymentMap = new Map<Id, blng__Payment__c>();
        paymentMap.put(payment.Id, payment);
        setPaymentIds.add(payment.Id);
        System.assertEquals('Draft', inv.blng__InvoiceStatus__c,'Error');
        MockPaymentDatabaseImpl mpdl = new MockPaymentDatabaseImpl();
        mpdl.returnValueQueryInvoiceByIdAndStatus = new Map<Id, blng__Invoice__c>();
        mpdl.returnValueQueryInvoiceByIdAndStatus.put(invoice.Id, invoice);
        mpdl.returnValueQueryInvoiceLinesByInvoiceId = new List<blng__InvoiceLine__c> { invoiceLine };
        mpdl.returnValueQueryInvoiceByOrderIdAndStatus = new Map<Id, blng__Invoice__c>();
        mpdl.paymentBalance = 10;
        mpdl.invoiceBalance = 10;

        // Need a second invoice
        blng__Invoice__c invoice2 = TestUtilities.createInvoice(account, anOrder, false);
        lstInvIds.add(invoice2.Id);
        setInvIds.add(invoice2.Id);
        lstInvStatus.add(invoice2.blng__InvoiceStatus__c);
        invoice2.Schedule_Number__c = 2;
        mpdl.returnValueQueryInvoiceByOrderIdAndStatus.put(invoice.Id, invoice);
        mpdl.returnValueQueryInvoiceByOrderIdAndStatus.put(invoice2.Id, invoice2);
        mpdl.returnValueQueryPaymentAllocationInvoiceByPaymentId = new Map<Id, blng__PaymentAllocationInvoice__c>();
        PaymentHandler ph = new PaymentHandler();
        PaymentHandler pmtHandler = new PaymentHandler(mpdl);
        Test.startTest();
        pmtHandler.handlePaymentAllocations(paymentMap);
        PaymentHandler.PaymentHandlerDefaultDatabaseImpl phdefaultdatatbase = new PaymentHandler.PaymentHandlerDefaultDatabaseImpl();
        phdefaultdatatbase.queryInvoiceByIdAndStatus(lstInvIds, lstInvStatus);
        phdefaultdatatbase.queryInvoiceLinesByInvoiceId(setInvIds);
        phdefaultdatatbase.queryInvoiceByOrderIdAndStatus(lstOrderIds, lstInvStatus);
        phdefaultdatatbase.queryPaymentAllocationInvoiceByPaymentId(setPaymentIds);
        phdefaultdatatbase.queryInvoicesByScheduleNumberAndInvoiceRun(2, lstInvRunsIds);
        phdefaultdatatbase.queryPaymentsByBalanceEqualAmountAndAccounts(True, setAccIds);
        phdefaultdatatbase.getPaymentBalance(payment);
        phdefaultdatatbase.getInvoiceBalance(invoice);
        Test.stopTest();
    }

    static testMethod void testUpdatePaymentInvoiceValue() {

        Map<String, SObject> sbObjectMap = TestUtilities.createToInvoiceStack(false);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Order anOrder = (Order) sbObjectMap.get(TestUtilities.ORDER);
        blng__Invoice__c invoice = (blng__Invoice__c) sbObjectMap.get(TestUtilities.INVOICE);
        blng__Payment__c payment = TestUtilities.createPayment(account, invoice, false);
        MockPaymentDatabaseImpl mpdl = new MockPaymentDatabaseImpl();
        mpdl.returnValueQueryInvoicesByScheduleNumberAndInvoiceRun = new List<blng__Invoice__c> {invoice};
        mpdl.returnValueQueryPaymentsByBalanceEqualAmountAndAccounts = new List<blng__Payment__c> {payment};

        PaymentHandler pmtHandler = new PaymentHandler(mpdl);
        Id invoiceRunId = TestUtilities.getFakeId(blng__InvoiceRun__c.getSObjectType());
        Test.startTest();
        pmtHandler.updatePaymentInvoiceValue(new List<Id> {invoiceRunId});
        Test.stopTest();
        System.assertEquals(1, mpdl.updatedPayments.size(),'Error');
    }

    static testMethod void testRollupPaymentTotalsForContract() {

        Map<String, SObject> sbObjectMap = TestUtilities.createToInvoiceStack(false);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Order anOrder = (Order) sbObjectMap.get(TestUtilities.ORDER);
        blng__Invoice__c invoice = (blng__Invoice__c) sbObjectMap.get(TestUtilities.INVOICE);
        blng__Payment__c payment = TestUtilities.createPayment(account, invoice, false);
        Contract contract1 = TestUtilities.createContract(account, null, false);
        payment.RelatedContract__c = contract1.Id;

        MockPaymentDatabaseImpl mpdl = new MockPaymentDatabaseImpl();
        mpdl.returnValueQueryPaymentsByRelatedContracts = new List<blng__Payment__c> {payment};
        mpdl.returnValueQueryContractsById = new Map<Id, Contract> (new List<Contract> {contract1});

        PaymentHandler pmtHandler = new PaymentHandler(mpdl);
        Test.startTest();
        pmtHandler.rollupPaymentTotalsForContract(new Map<Id, blng__Payment__c> (new List<blng__Payment__c> {payment}));
        Test.stopTest();
        System.assertEquals(1, mpdl.updatedContracts.size(),'Error');
    }
    /**
     * @discription MockPaymentDatabaseImpl
     */
    public class MockPaymentDatabaseImpl implements PaymentHandler.PaymentHandlerDatabaseInterface {
        /**
         * returnValueQueryInvoiceByIdAndStatus
         * @description wrapper variable
         */
        public Map<Id, blng__Invoice__c> returnValueQueryInvoiceByIdAndStatus { get; set; }
        /**
         * returnValueQueryInvoiceLinesByInvoiceId
         * @description wrapper variable
         */
        public List<blng__InvoiceLine__c> returnValueQueryInvoiceLinesByInvoiceId { get; set; }
        /**
         * returnValueQueryInvoiceByOrderIdAndStatus
         * @description wrapper variable
         */
        public Map<Id, blng__Invoice__c> returnValueQueryInvoiceByOrderIdAndStatus { get; set; }
        /**
         * returnValueQueryPaymentAllocationInvoiceByPaymentId
         * @description wrapper variable
         */
        public Map<Id, blng__PaymentAllocationInvoice__c> returnValueQueryPaymentAllocationInvoiceByPaymentId { get; set; }
        /**
         * insertPaymentAllocationInvoices
         * @description wrapper variable
         */
        public List<blng__PaymentAllocationInvoice__c> insertPaymentAllocationInvoices { get; set; }
        /**
         * returnValueQueryInvoicesByScheduleNumberAndInvoiceRun
         * @description wrapper variable
         */
        public List<blng__Invoice__c> returnValueQueryInvoicesByScheduleNumberAndInvoiceRun {get; set;}
        /**
         * returnValueQueryPaymentsByBalanceEqualAmountAndAccounts
         * @description wrapper variable
         */
        public List<blng__Payment__c> returnValueQueryPaymentsByBalanceEqualAmountAndAccounts {get; set;}
        /**
         * returnValueQueryPaymentsByRelatedContracts
         * @description wrapper variable
         */
        public List<blng__Payment__c> returnValueQueryPaymentsByRelatedContracts {get; set;}
        /**
         * returnValueQueryContractsById
         * @description wrapper variable
         */
        public Map<Id, Contract> returnValueQueryContractsById {get; set;}
        /**
         * paymentBalance
         * @description wrapper variable
         */
        public Decimal paymentBalance { get; set; }
        /**
         * invoiceBalance
         * @description wrapper variable
         */
        public Decimal invoiceBalance { get; set; }
        /**
         * updatedPayments
         * @description wrapper variable
         */
        public List<blng__Payment__c> updatedPayments;
        /**
         * updatedContracts
         * @description wrapper variable
         */
        public List<Contract> updatedContracts;
        /**
         * @description query method for invoices
         * @param  invoiceIds      invoice ids
         * @param  invoiceStatuses invoice statuses
         * @return                 None
         */
        public Map<Id, blng__Invoice__c> queryInvoiceByIdAndStatus(List<Id> invoiceIds, List<String> invoiceStatuses) {
            return returnValueQueryInvoiceByIdAndStatus;
        }
        /**
         * @description query method for invoices
         * @param  invoiceIds invoice ids
         * @return            None
         */
        public List<blng__InvoiceLine__c> queryInvoiceLinesByInvoiceId(Set<Id> invoiceIds) {
            return returnValueQueryInvoiceLinesByInvoiceId;
        }
        /**
         * @description invoice query by order id
         * @param  orderIds      order ids
         * @param  invoiceStatus invoice status
         * @return               None
         */
        public Map<Id, blng__Invoice__c> queryInvoiceByOrderIdAndStatus(List<Id> orderIds, List<String> invoiceStatus) {
            return returnValueQueryInvoiceByOrderIdAndStatus;
        }
        /**
         * @description query payment allocation invoices
         * @param  paymentIds payment ids
         * @return            None
         */
        public Map<Id, blng__PaymentAllocationInvoice__c> queryPaymentAllocationInvoiceByPaymentId(Set<Id> paymentIds) {
            return returnValueQueryPaymentAllocationInvoiceByPaymentId;
        }
        /**
         * description invoice query by schedule number
         * @param  scheduleNumber schedule
         * @param  invoiceRuns    invoice runs
         * @return                None
         */
        public List<blng__Invoice__c> queryInvoicesByScheduleNumberAndInvoiceRun(Integer scheduleNumber, List<Id> invoiceRuns) {
            return returnValueQueryInvoicesByScheduleNumberAndInvoiceRun;
        }
        /**
         * @description query payment by balance equals amount and account
         * @param  balanceEqualAmount balance
         * @param  accountIds         account ids
         * @return                    None
         */
        public List<blng__Payment__c> queryPaymentsByBalanceEqualAmountAndAccounts(Boolean balanceEqualAmount, Set<Id> accountIds) {
            return returnValueQueryPaymentsByBalanceEqualAmountAndAccounts;
        }
        /**
         * @description query payment by related contract
         * @param  relatedContractIds related contracts
         * @return                    None
         */
        public List<blng__Payment__c> queryPaymentsByRelatedContracts(Set<Id> relatedContractIds) {
            return returnValueQueryPaymentsByRelatedContracts;
        }
        /**
         * @description query contract by Id
         * @param  contractIds contract ids
         * @return             None
         */
        public Map<Id, Contract> queryContractsById(Set<Id> contractIds) {
            return returnValueQueryContractsById;
        }
        /**
         * @description get payment balance
         * @param  payment payment
         * @return         None
         */
        public Decimal getPaymentBalance(blng__Payment__c payment) {
            return paymentBalance;
        }
        /**
         * @description get invoice balance
         * @param  invoice invoice
         * @return         NOne
         */
        public Decimal getInvoiceBalance(blng__Invoice__c invoice) {
            return invoiceBalance;
        }
        /**
         * @description payment allocation insertion
         * @param paymentAllocationInvoices paymentallocation list
         */
        public void insertPaymentAllocationInvoice(List<blng__PaymentAllocationInvoice__c> paymentAllocationInvoices) {
            insertPaymentAllocationInvoices = paymentAllocationInvoices;
        }
        /**
         * @description updatePayments
         * @param updatePayments list of payments
         */
        public void updatePayments(List<blng__Payment__c> updatePayments) {
            updatedPayments = updatePayments;
        }
        /**
         * @description contract update
         * @param updateContracts contract list
         */
        public void updateContracts(List<Contract> updateContracts) {
            updatedContracts = updateContracts;
        }
    }
}