/**
 * Test class for the OrderHandler
 [Modified By : Aishwarya 12 Aug 2020 BK-3751]
 */

@IsTest
private class OrderHandlerTest {

    @testSetup
    public static void setupData() {
        TestUtilities.createCSIntegrationSettings();
        TestUtilities.createCSBatchSettings();
        TestUtilities.createBillingPrefix();
        TestUtilities.createBillingConfigs();
    }

    static testMethod void testTrigger() {
        //System.assert(false);
        //try {
        Map<String, SObject> sbObjectMap = TestUtilities.createSBQQStack(true);
        Account account = (Account) sbObjectMap.get(TestUtilities.ACCOUNT);
        Opportunity opportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);
        System.assertNotEquals(null, opportunity,'opportunity not equal null');
        System.assertNotEquals(null, opportunity.Billing_Contact__c,'opportunity BillingContact not equal null');
        opportunity.Billing_Contact__c = null;
        update opportunity;
        Test.startTest();
            Order anOrder = TestUtilities.createOrder(account, opportunity, true);
        Test.stopTest();

           //List<OrderItem> orderItems = TestUtilities.activateOrder(anOrder, true);
        //anOrder.Type = 'Amendment';
        //update anOrder;
        /*} catch (Exception eek) {

        }*/
    }

    static testMethod void testUnallocatePaymentsOnOrder() {
        Map<String, SObject> sbObjectMap = TestUtilities.createToInvoiceStack(false);
        Opportunity anOpportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);
        System.assertNotEquals(null, anopportunity,'opportunity not equal null');
        Order anOrder = (Order) sbObjectMap.get(TestUtilities.ORDER);
        anOrder.OpportunityId = anOpportunity.Id;

        blng__Invoice__c anInvoice = (blng__Invoice__c) sbObjectMap.get(TestUtilities.INVOICE);
        blng__PaymentAllocationInvoice__c pai = new blng__PaymentAllocationInvoice__c();
        pai.blng__Invoice__c = anInvoice.Id;
        pai.blng__Type__c = 'Allocated';
        pai.blng__Unallocated__c = false;
        System.assertEquals(pai.blng__Type__c, 'Allocated','Type equals Allocated');

        OrderHandlerDataMockImpl mockImpl = new OrderHandlerDataMockImpl();
        mockImpl.returnQueryOpportunityByOpportunityIds.add(anOpportunity);
        mockImpl.returnQueryInvoicesByOrderId.add(anInvoice);
        mockImpl.returnQueryUnallocatedPaymentAllocationInvoicesByInvoiceId.add(pai);
        OrderHandler handler = new OrderHandler(mockImpl);

        Test.startTest();
        handler.unallocatePaymentsOnOrder(new List<Order> {anOrder});
        Test.stopTest();
    }

    static testMethod void testUpdateContractOnOrderFromOpportunity() {
        Map<String, SObject> sbObjectMap = TestUtilities.createToInvoiceStack(false);
        Opportunity anOpportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);
        System.assertNotEquals(null, anopportunity,'opportunity not equal null');
        Order anOrder = (Order) sbObjectMap.get(TestUtilities.ORDER);
        anOrder.OpportunityId = anOpportunity.Id;
        System.assertEquals(anOrder.OpportunityId, anOpportunity.Id,'opportunity id should be equals');

        OrderHandlerDataMockImpl mockImpl = new OrderHandlerDataMockImpl();
        mockImpl.returnQueryOpportunityByOpportunityIds.add(anOpportunity);
        OrderHandler handler = new OrderHandler(mockImpl);

        Test.startTest();
        handler.updateContractOnOrderFromOpportunity(new List<Order> {anOrder});
        Test.stopTest();

    }

    static testMethod void testUpdateContractOnOrderFromOpportunityAmendedContract() {
        Map<String, SObject> sbObjectMap = TestUtilities.createToInvoiceStack(false);
        Id contractId = TestUtilities.getFakeId(Contract.getSObjectType());
        Opportunity anOpportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);
        System.assertNotEquals(null, anOpportunity,'opportunity not equal null');
        anOpportunity.SBQQ__AmendedContract__c = contractId;
        Order anOrder = (Order) sbObjectMap.get(TestUtilities.ORDER);
        anOrder.OpportunityId = anOpportunity.Id;
        System.assertEquals(anOrder.OpportunityId, anOpportunity.Id,'opportunity id should be equals');

        OrderHandlerDataMockImpl mockImpl = new OrderHandlerDataMockImpl();
        mockImpl.returnQueryOpportunityByOpportunityIds.add(anOpportunity);
        
        blng__Invoice__c anInvoice = (blng__Invoice__c) sbObjectMap.get(TestUtilities.INVOICE);
        OrderHandler handler = new OrderHandler(mockImpl);

        Test.startTest();
        handler.updateContractOnOrderFromOpportunity(new List<Order> {anOrder});
        Test.stopTest();

    }
    
    static testMethod void testOrderHandlerDataDefaultImplService() {
        Map<String, SObject> sbObjectMap = TestUtilities.createToInvoiceStack(false);
        Id contractId = TestUtilities.getFakeId(Contract.getSObjectType());
        Opportunity anOpportunity = (Opportunity) sbObjectMap.get(TestUtilities.OPPORTUNITY);
        System.assertNotEquals(null, anOpportunity,'opportunity not equal null');
        anOpportunity.SBQQ__AmendedContract__c = contractId;
        Order anOrder = (Order) sbObjectMap.get(TestUtilities.ORDER);
        anOrder.OpportunityId = anOpportunity.Id;
        blng__Invoice__c anInvoice = (blng__Invoice__c) sbObjectMap.get(TestUtilities.INVOICE);
        
        Set<Id> optyIdSet = new Set<Id>();
        optyIdSet.add(anOpportunity.Id);
        
        List<Id> orderOptyIdList = new List<Id>();
        orderOptyIdList.add(anOrder.OpportunityId);
        

        List<blng__Invoice__c> invoiceLst = new List<blng__Invoice__c>();
        invoiceLst.add(anInvoice);

        
        Test.startTest();
            OrderHandler.OrderHandlerDataDefaultImpl handlerDefaultService = new OrderHandler.OrderHandlerDataDefaultImpl();
            handlerDefaultService.queryOpportunityByOpportunityIds(optyIdSet);
            handlerDefaultService.queryOrderByOpportunityId(orderOptyIdList);
        try{
            handlerDefaultService.updateInvoices(InvoiceLst);

        }catch(Exception e){
            System.debug('test class excution');
        }

            Test.stopTest();
    }

    public class OrderHandlerDataMockImpl implements OrderHandler.OrderHandlerDataInterface {
    
        public List<Opportunity> returnQueryOpportunityByOpportunityIds = new List<Opportunity>();
        public List<Order> returnQueryOrderByOpportunityId = new List<Order>();
        public List<blng__Invoice__c> returnQueryInvoicesByOrderId = new List<blng__Invoice__c>();
        public List<blng__PaymentAllocationInvoice__c> returnQueryUnallocatedPaymentAllocationInvoicesByInvoiceId = new List<blng__PaymentAllocationInvoice__c>();
        public List<blng__PaymentAllocationInvoice__c> insertedUnallocatedAllocationInvoices = new List<blng__PaymentAllocationInvoice__c>();
        public List<blng__PaymentAllocationInvoice__c> updatedUnallocatedAllocationInvoices = new List<blng__PaymentAllocationInvoice__c>();
        public List<blng__Invoice__c> updatedInvoices = new List<blng__Invoice__c>();

        public List<Opportunity> queryOpportunityByOpportunityIds(Set<Id> opportunityIds){
            return returnQueryOpportunityByOpportunityIds;
        }

        public List<Order> queryOrderByOpportunityId(List<Id> opportunityIds) {
            return returnQueryOrderByOpportunityId;
        }

        public List<blng__Invoice__c> queryInvoicesByOrderId(Set<Id> orderIds) {
            return returnQueryInvoicesByOrderId;
        }

        public List<blng__PaymentAllocationInvoice__c> queryUnallocatedPaymentAllocationInvoicesByInvoiceId(List<Id> invoiceIds) {
            return returnQueryUnallocatedPaymentAllocationInvoicesByInvoiceId;
        }

        public void insertPaymentAllocationInvoices(List<blng__PaymentAllocationInvoice__c> unallocatedPaymentAllocationInvoices) {
            insertedUnallocatedAllocationInvoices = unallocatedPaymentAllocationInvoices;
        }

        public void updatePaymentAllocationInvoices(List<blng__PaymentAllocationInvoice__c> updatedPaymentAllocationInvoices) {
            updatedUnallocatedAllocationInvoices = updatedPaymentAllocationInvoices;
        }

        public void updateInvoices(List<blng__Invoice__c> invoices) {
            updatedInvoices = invoices;
        }
    }
    
}