/**
 * Handles events around the Order object.
 */

public with sharing class OrderHandler {
    private OrderHandlerDataInterface dataInterface;

    public OrderHandler() {
        dataInterface = new OrderHandlerDataDefaultImpl();
    }

    public OrderHandler(OrderHandlerDataInterface altInterface) {
        dataInterface = altInterface;
    }

    public void unallocatePaymentsOnOrder(List<Order> orderList, Map<Id, Order> oldMap) {
        List<Order> amendOrders = new List<Order>();

        for (Order anOrder: orderList) {
            // Only need to build up the list of amendment orders and which are being activated right now.
            if (anOrder.Type == 'Amendment' && anOrder.Status == 'Activated' && oldMap.get(anOrder.Id).Status != 'Activated') 
            {
                amendOrders.add(anOrder);
            }
        }
        if (amendOrders.size() > 0) {
            System.debug('OrderHandler unallocatePaymentsOnOrder: ' + amendOrders);
            unallocatePaymentsOnOrder(amendOrders);
        }
    }

    /**
     * Looks for the existing Invoices on the amended contract and unallocated the payments and marks the invoices
     * as needing to be cancel and rebilled.
     */
    public void unallocatePaymentsOnOrder(List<Order> orderList) {
        System.debug('OrderHandler.unallocatePaymentsOnOrder() ' + orderList);
        Map<Id, Order> ordersByIds = new Map<Id, Order>();
        Map<Id, Order> ordersByOpportunityIds = new Map<Id, Order>();
        for(Order order: orderList) {
            ordersByIds.put(order.Id, order);
            ordersByOpportunityIds.put(order.OpportunityId, order);
        }

        System.debug('OrderHandler.unallocatePaymentsOnOrder() ordersByOpportunityIds.keySet() ' + ordersByOpportunityIds.keySet());
        Map<Id, Opportunity> opportunitiesByIds = new Map<Id, Opportunity>(dataInterface.queryOpportunityByOpportunityIds(ordersByOpportunityIds.keySet()));

        Map<Id, Opportunity> opportunitiesByContractIds = new Map<Id, Opportunity>();
        List<Id> opportunityIds = new List<Id>();
        for(Opportunity opportunity: opportunitiesByIds.values())
        {
            //opportunitiesByContractIds.put(opportunity.SBQQ__AmendedContract__c, opportunity);
            opportunityIds.add(opportunity.SBQQ__AmendedContract__r.SBQQ__Opportunity__c);
        }

        /*System.debug('OrderHandler.cancelAndRebillOldInvoices() opportunitiesByContractIds.keySet() ' + opportunitiesByContractIds.keySet());
        Map<Id, Contract> contractByIds = new Map<Id, Contract>([SELECT Id, SBQQ__Opportunity__c FROM Contract WHERE Id IN : opportunitiesByContractIds.keySet()]);

        for(Contract contract: contractByIds.values()){
            opportunityIds.add(contract.SBQQ__Opportunity__c);
        }              */
        System.debug('OrderHandler.unallocatePaymentsOnOrder() opportunityIds ' + opportunityIds);

        Map<Id, Order> originalOrdersById = new Map<Id, Order>(dataInterface.queryOrderByOpportunityId(opportunityIds));

        System.debug('OrderHandler.unallocatePaymentsOnOrder() originalOrdersById.keySet() ' + originalOrdersById.keySet());
        List<blng__Invoice__c> invoices = dataInterface.queryInvoicesByOrderId(originalOrdersById.keySet());
        System.debug('OrderHandler.unallocatePaymentsOnOrder() invoices: ' + invoices);
        System.debug('OrderHandler.unallocatePaymentsOnOrder() SOQL Limits before: ' + Limits.getQueries());
        List<Id> invoiceIds = new List<Id>();

        List<blng__Invoice__c> updateInvoices = new List<blng__Invoice__c>();
        for(blng__Invoice__c invoice: invoices) {
            invoiceIds.add(invoice.Id);
            // Flag the invoices retrieved to be cancelled and rebilled at a future date.
            if(invoice.blng__InvoiceStatus__c != 'Cancelled') {
                invoice.Cancel_and_Rebill__c = true;
                updateInvoices.add(invoice);
            }
        }

        List<blng__PaymentAllocationInvoice__c> paymentAllocationInvoices = dataInterface.queryUnallocatedPaymentAllocationInvoicesByInvoiceId(invoiceIds);

        List<blng__PaymentAllocationInvoice__c> unallocatePaymentAllocationInvoices = new List<blng__PaymentAllocationInvoice__c>();
        List<blng__PaymentAllocationInvoice__c> updatePaymentAllocationInvoices = new List<blng__PaymentAllocationInvoice__c>();
        for(blng__PaymentAllocationInvoice__c pai: paymentAllocationInvoices) {
            blng__PaymentAllocationInvoice__c unPai = new blng__PaymentAllocationInvoice__c();
            unPai.blng__Invoice__c = pai.blng__Invoice__c;
            unPai.blng__Payment__c = pai.blng__Payment__c;
            unPai.blng__Type__c = 'Unallocation';
            //unPai.blng__Unallocated__c = true;
            unPai.blng__Amount__c = pai.blng__Amount__c;
            unallocatePaymentAllocationInvoices.add(unPai);

            pai.blng__Unallocated__c = TRUE;
            updatePaymentAllocationInvoices.add(pai);
        }

        System.debug('OrderHandler.unallocatePaymentsOnOrder() unallocates: ' + unallocatePaymentAllocationInvoices);
        if(unallocatePaymentAllocationInvoices.size() > 0) {
            dataInterface.insertPaymentAllocationInvoices(unallocatePaymentAllocationInvoices);
        }

        System.debug('OrderHandler.unallocatePaymentsOnOrder() updatePaymentAllocationInvoices: ' + updatePaymentAllocationInvoices);
        if(updatePaymentAllocationInvoices.size() > 0) {
            dataInterface.updatePaymentAllocationInvoices(updatePaymentAllocationInvoices);
        }

        System.debug('OrderHandler.unallocatePaymentsOnOrder() updateInvoices: ' + updateInvoices);
        if(updateInvoices.size() > 0) {
            dataInterface.updateInvoices(updateInvoices);
        }
    }

    /**
     * Updates the order with the amended contract.
     */
    public void updateContractOnOrderFromOpportunity(List<Order> orderList) {
        System.debug('OrderHandler.updateContractOnOrderFromOpportunity() ' + orderList);
        Map<Id, Order> ordersByIds = new Map<Id, Order>();
        Map<Id, Order> ordersByOpportunityIds = new Map<Id, Order>();
        for(Order order: orderList) {
            ordersByIds.put(order.Id, order);
            ordersByOpportunityIds.put(order.OpportunityId, order);
        }

        System.debug('OrderHandler.updateContractOnOrderFromOpportunity() ordersByOpportunityIds.keySet() ' + ordersByOpportunityIds.keySet());
        Map<Id, Opportunity> opportunitiesByIds = new Map<Id, Opportunity>(dataInterface.queryOpportunityByOpportunityIds(ordersByOpportunityIds.keySet()));


        for(Order order: orderList) {
            if(opportunitiesByIds.containsKey(order.OpportunityId)){
                if(opportunitiesByIds.get(order.OpportunityId).SBQQ__AmendedContract__c != null) {
                    order.ContractId = opportunitiesByIds.get(order.OpportunityId).SBQQ__AmendedContract__c;
                } else {
                    order.ContractId = opportunitiesByIds.get(order.OpportunityId).ContractId;
                }

            }

        }
    }

    public interface OrderHandlerDataInterface {

        List<Opportunity> queryOpportunityByOpportunityIds(Set<Id> opportunityIds);

        List<Order> queryOrderByOpportunityId(List<Id> opportunityIds);

        List<blng__Invoice__c> queryInvoicesByOrderId(Set<Id> orderIds);

        List<blng__PaymentAllocationInvoice__c> queryUnallocatedPaymentAllocationInvoicesByInvoiceId(List<Id> invoiceIds);

        void insertPaymentAllocationInvoices(List<blng__PaymentAllocationInvoice__c> unallocatedPaymentAllocationInvoices);

        void updatePaymentAllocationInvoices(List<blng__PaymentAllocationInvoice__c> updatedPaymentAllocationInvoices);

        void updateInvoices(List<blng__Invoice__c> invoices);

    }

       public class OrderHandlerDataDefaultImpl implements OrderHandler.OrderHandlerDataInterface {
        public List<Opportunity> queryOpportunityByOpportunityIds(Set<Id> opportunityIds){
            return [SELECT Id, ContractId, SBQQ__AmendedContract__c, SBQQ__AmendedContract__r.SBQQ__Opportunity__c FROM Opportunity WHERE Id IN :opportunityIds];
        }

        public List<Order> queryOrderByOpportunityId(List<Id> opportunityIds) {
            return [SELECT Id, OpportunityId FROM Order WHERE OpportunityId IN :opportunityIds];
        }

        public List<blng__Invoice__c> queryInvoicesByOrderId(Set<Id> orderIds) {
            return [SELECT Id, blng__InvoiceStatus__c, blng__Order__c, blng__ARStatus__c, blng__PaymentStatus__c FROM blng__Invoice__c WHERE blng__Order__c IN :orderIds];
        }

        public List<blng__PaymentAllocationInvoice__c> queryUnallocatedPaymentAllocationInvoicesByInvoiceId(List<Id> invoiceIds) {
            return [SELECT Id, blng__Invoice__c, blng__Payment__c,blng__Type__c, blng__Unallocated__c, blng__Amount__c  FROM blng__PaymentAllocationInvoice__c WHERE blng__Invoice__c IN :invoiceIds AND blng__Unallocated__c = FALSE AND blng__Type__c = 'Allocation'];
        }

        public void insertPaymentAllocationInvoices(List<blng__PaymentAllocationInvoice__c> unallocatedPaymentAllocationInvoices) {
            insert unallocatedPaymentAllocationInvoices;
        }

        public void updatePaymentAllocationInvoices(List<blng__PaymentAllocationInvoice__c> updatedPaymentAllocationInvoices) {
            update updatedPaymentAllocationInvoices;
        }

        public void updateInvoices(List<blng__Invoice__c> invoices) {
            update invoices;
        }
    }

}