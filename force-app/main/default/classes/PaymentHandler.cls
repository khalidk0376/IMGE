/**
     * File:          PaymentHandler
     * Project:       GAP
     * Date:          28/7/2017
     * Created By:    Margaret Persico
     * Test Class :   PaymentHandlerTest
    
    
    * *************************************************************************
     * @description Class to handle the functions performed by the PaymentTrigger
     * *************************************************************************
     * History : Modified By Yash Gupta [GGCW-2863]
     *           Modified By Avinash Shukla : BK-18 16/07/2019
     *           Modified By Adarsh Sharma : BK-3458
     * Ticket No.-BK-14522 Updating API Version
     */
    
    public without sharing class PaymentHandler {
        /**
        * @description interface databaseInterface.
        */
        private PaymentHandlerDatabaseInterface databaseInterface;
    
        /**
         * @description Constructor, this contains the instance of databaseInterface.
         */
        public PaymentHandler() {
            databaseInterface = new PaymentHandlerDefaultDatabaseImpl();
        }
    
        /**
         * @description Constructor(dbInterface).
         */
        public PaymentHandler(PaymentHandlerDatabaseInterface dbInterface) {
            databaseInterface = dbInterface;
        }
    
        /**
         * @description handlePaymentAllocations
         * @param paymentMap Map of payment.
         */
        public void handlePaymentAllocations(Map<Id, blng__Payment__c> paymentMap) {
            // Build Map of payment ids to invoice ids  and invoice ids to payment ids
            Map<Id, Id> paymentIdToInvoiceIdMap = new Map<Id, Id>();
            Map<Id, Id> invoiceIdToPaymentIdMap = new Map<Id, Id>();
            Set<Id> setOrderIds = new Set<Id>();
            Set<Id> setInvoiceId = new Set<Id>();
            AddContractandOrderOnPayment_class objAddContractandOrderOnPayment = new AddContractandOrderOnPayment_class(paymentMap.values() , paymentMap);
            objAddContractandOrderOnPayment.addOrderfromInvoice ();
            for (blng__Payment__c payment : paymentMap.values()) {
                paymentIdToInvoiceIdMap.put(payment.Id, payment.blng__Invoice__c);
                invoiceIdToPaymentIdMap.put(payment.blng__Invoice__c, payment.Id);
                if (payment.Order_from_Invoice__c != null) { setOrderIds.add(payment.Order_from_Invoice__c); } /*else {
                    payment.Order_from_Invoice__c.addError(System.Label.Label_Missing_Order_Id);
                }*/
            }
            // Retrieve & Build Map of Related Invoices to the payments
            Map<Id, blng__Invoice__c> invoiceIdToPaymentInvoiceMap = databaseInterface.queryInvoiceByIdAndStatus(paymentIdToInvoiceIdMap.values(), new List<String> {'Draft', 'Posted'});
            List<blng__InvoiceLine__c> invoiceLines = databaseInterface.queryInvoiceLinesByInvoiceId(invoiceIdToPaymentIdMap.keySet());
    
            // Build list of payments that have invoices first in the schedule.
            List<Id> orderIds = new List<Id>();
            Map<Id, Id> invoiceIdToFirstInvoiceIdMap = new  Map<Id, Id>();
            for (blng__Invoice__c invoice : invoiceIdToPaymentInvoiceMap.values()) {
                if (invoice.Schedule_Number__c == 1) { invoiceIdToFirstInvoiceIdMap.put(invoice.Id, invoice.Id); } else { invoiceIdToFirstInvoiceIdMap.put(invoice.Id, invoice.First_Invoice__c); }
    
                if (invoice.blng__Order__c != null) {
                    orderIds.add(invoice.blng__Order__c);
                } else {
                    // For some reason the order value wasn't updated on the invoice so we go through the invoice lines to find the order id.
                    for (blng__InvoiceLine__c invoiceLine : invoiceLines) {
                        if (invoiceLine.blng__Invoice__c == invoice.Id) {
                            orderIds.add(invoiceLine.blng__OrderProduct__r.OrderId);
                            break;
                        }
                    }
                }
            }
    
            invoiceIdToPaymentInvoiceMap.putAll(databaseInterface.queryInvoiceByIdAndStatus(invoiceIdToFirstInvoiceIdMap.values(), new List<String> {'Draft', 'Posted'}));
    
            // Retrieve all the invoices related to the first invoice order.
            Map<Id, blng__Invoice__c> invoiceIdRelatedToOrdersMap = databaseInterface.queryInvoiceByOrderIdAndStatus(orderIds, new List<String> {'Draft', 'Posted'});
    
            // Build a mapping of the orders to the subsequent invoices. first invoices are in the invoiceIdToPaymentInvoiceMap
            Map<Id, List<blng__Invoice__c>> orderIdToListInvoicesMap = new Map<Id, List<blng__Invoice__c>>();
            List<blng__Invoice__c> listInvoices = new List<blng__Invoice__c>();
    
            // Added this to track invoice balances for bug fix
            Map<Id, Decimal> invoiceIdToBalanceMap = new Map<Id, Decimal>();
            for (blng__Invoice__c invoice : invoiceIdRelatedToOrdersMap.values()) {
                invoiceIdToBalanceMap.put(invoice.Id, databaseInterface.getInvoiceBalance(invoice));
                //Modified By Avinash Shukla : BK-18
                //if (invoice.Schedule_Number__c != 1) {
                if (orderIdToListInvoicesMap.containsKey(invoice.blng__Order__c)) { listInvoices = orderIdToListInvoicesMap.get(invoice.blng__Order__c); } else {
                    listInvoices = new List<blng__Invoice__c>();
                }
                listInvoices.add(invoice);
                orderIdToListInvoicesMap.put(invoice.blng__Order__c, listInvoices);
                //}
            }
    
            // Retrieve any existing payment allocations
            Map<Id, blng__PaymentAllocationInvoice__c> paymentAllocationInvoiceMap = databaseInterface.queryPaymentAllocationInvoiceByPaymentId(paymentMap.keySet());
    
            /*
                @description As per ticket no. GGCW-2863 we have to give an error message when
            */
            Integer iPaymentSize = 0;
            List<blng__Invoice__c> lstInvoice = [SELECT Id, blng__Order__c, (Select id from blng__Payments__r) FROM blng__Invoice__c where blng__Order__c = :setOrderIds and Schedule_Number__c = 1 and blng__InvoiceStatus__c != 'cancelled'];
            if (lstInvoice.size() > 0) {
                for (blng__Invoice__c invoiceInst : lstInvoice) {
                    for (blng__Payment__c billPay : invoiceInst.blng__Payments__r) { iPaymentSize = invoiceInst.blng__Payments__r.size(); }
                }
            }
    
            List<blng__PaymentAllocationInvoice__c> paymentAllocationInvoiceInsert = new List<blng__PaymentAllocationInvoice__c>();
            for (Id firstPaymentId : paymentMap.keySet()) {
                blng__Payment__c payment = paymentMap.get(firstPaymentId);
                if (payment != null && databaseInterface.getPaymentBalance(payment) > 0) {
                    Decimal runningPaymentBalance = databaseInterface.getPaymentBalance(payment);
                    blng__Invoice__c firstInvoice = invoiceIdToPaymentInvoiceMap.get(invoiceIdToFirstInvoiceIdMap.get(payment.blng__Invoice__c));
                    List<InvoiceWrapper> orderInvoiceWrappers = new List<InvoiceWrapper>();
                    blng__Invoice__c paymentInvoice;
                    if (iPaymentSize > 0) {
                        if (firstInvoice != null) {
                            if (payment.blng__Invoice__c == firstInvoice.Id) {paymentInvoice = firstInvoice;
                            } else {
                                orderInvoiceWrappers.add(new InvoiceWrapper(firstInvoice));
                            }
                        }
                    }
                    /*else if (payment.Order_from_Invoice__c == null) {
                        payment.Order_from_Invoice__c.addError(System.Label.Label_Missing_Order_Id);
                    }
                    else { payment.addError(System.Label.Pay_Old_Invoice_Label); }*/
                    if (firstInvoice != null) {
                        if (firstInvoice.blng__Order__c != null && orderIdToListInvoicesMap.containsKey(firstInvoice.blng__Order__c)) {
                            for (blng__Invoice__c wrapInvoice : orderIdToListInvoicesMap.get(firstInvoice.blng__Order__c)) {
                                if (wrapInvoice.Id == payment.blng__Invoice__c) { paymentInvoice = wrapInvoice;} else {
                                    orderInvoiceWrappers.add(new InvoiceWrapper(wrapInvoice));
                                }
                            }
                        }
                    }
    
                    orderInvoiceWrappers.sort();
                    InvoiceWrapper paymentInvoiceWrapper = new InvoiceWrapper(paymentInvoice);
                    if (orderInvoiceWrappers.size() > 0) { orderInvoiceWrappers.add(0, paymentInvoiceWrapper);} else { orderInvoiceWrappers.add(paymentInvoiceWrapper); }
                    List<blng__Invoice__c> orderInvoices = new List<blng__Invoice__c>();
                    if (firstInvoice != null) {
                        for (InvoiceWrapper wrapInvoice : orderInvoiceWrappers) {
                            If(wrapInvoice.inv != NULL) {
                                blng__Invoice__c invoice = wrapInvoice.inv;
                                Decimal currentInvoiceBalance = invoiceIdToBalanceMap.get(invoice.Id);
                                if (runningPaymentBalance > 0 && currentInvoiceBalance > 0) {
                                    blng__PaymentAllocationInvoice__c paymentAllocationInvoice = new blng__PaymentAllocationInvoice__c();
                                    paymentAllocationInvoice.blng__Invoice__c = invoice.Id;
                                    paymentAllocationInvoice.blng__Payment__c = payment.Id;
                                    paymentAllocationInvoice.blng__Type__c = 'Allocation';
                                    Decimal lessorAmount = 0.0;
                                    if (currentInvoiceBalance > runningPaymentBalance) { lessorAmount = runningPaymentBalance;
                                    } else {
                                        lessorAmount = currentInvoiceBalance;
                                    }
                                    runningPaymentBalance -= lessorAmount;
                                    invoiceIdToBalanceMap.put(invoice.Id, currentInvoiceBalance - lessorAmount);
                                    paymentAllocationInvoice.blng__Amount__c = lessorAmount;
                                    paymentAllocationInvoiceInsert.add(paymentAllocationInvoice);
                                }
                            }
                        }
                    }
                }
            }
    
            if (paymentAllocationInvoiceInsert.size() > 0) { databaseInterface.insertPaymentAllocationInvoice(paymentAllocationInvoiceInsert); }
        }
    
        /**
         * @description Updates the invoice setting on the payments from the accounts where there were open payments and the invoice was updated/created during the invoice run.
         */
        public void updatePaymentInvoiceValue(List<Id> invoiceRuns) {
    
            List<blng__Invoice__c> invoices = new List<blng__Invoice__c>();
            if (invoiceRuns.size() > 0) {
                invoices = databaseInterface.queryInvoicesByScheduleNumberAndInvoiceRun(1, invoiceRuns);
            }
    
            Map<Id, blng__Invoice__c> invoiceByAccountId = new Map<Id, blng__Invoice__c>();
            for (blng__Invoice__c invoice : invoices) {
                // Only want to capture the first invoice in the list as it is the latest invoice. Will it create multiple invoices on an account?
                if (!invoiceByAccountId.containsKey(invoice.blng__Account__c)) {
                    invoiceByAccountId.put(invoice.blng__Account__c, invoice);
                }
            }
    
            List<blng__Payment__c> payments = databaseInterface.queryPaymentsByBalanceEqualAmountAndAccounts(true, invoiceByAccountId.keySet());
            Map<Id, List<blng__Payment__c>> paymentsByAccountId = new Map<Id, List<blng__Payment__c>>();
            List<blng__Payment__c> paymentSubList = new List<blng__Payment__c>();
            for (blng__Payment__c payment : payments) {
                if (paymentsByAccountId.containsKey(payment.blng__Account__c)) { paymentSubList = paymentsByAccountId.get(payment.blng__Account__c);} else {
                    paymentSubList = new List<blng__Payment__c>();
                }
                paymentSubList.add(payment);
                paymentsByAccountId.put(payment.blng__Account__c, paymentSubList);
            }
    
            List<blng__Payment__c> updatePayments = new List<blng__Payment__c>();
            for (Id accountId : paymentsByAccountId.keySet()) {
                for (blng__Payment__c payment : paymentsByAccountId.get(accountId)) {
                    if (invoiceByAccountId.containsKey(accountId) && payment.RelatedContract__c == invoiceByAccountId.get(accountId).blng__Order__r.ContractId ) {
                        payment.blng__Invoice__c = invoiceByAccountId.get(accountId).Id;
                        updatePayments.add(payment);
                    }
                }
            }
    
            if (updatePayments.size() > 0) {
                databaseInterface.updatePayments(updatePayments);
            }
    
        }
    
        /**
         * @description Rolls up the payments for the contract.
         * After trigger assumed.
         * Takes the inserted, updated, deleted, undeleted payment, retrieves all the payments for the related contract then
         * sums up the values of the payments.
         */
        public void rollupPaymentTotalsForContract(Map<Id, blng__Payment__c> paymentByIds) {
            Set<Id> contractIds = new Set<Id>();
            for (blng__Payment__c payment : paymentByIds.values()) {
                if (payment.RelatedContract__c != null) {
                    contractIds.add(payment.RelatedContract__c);
                }
            }
    
            if (contractIds.size() > 0) {
                List<Contract> updateContracts = new List<Contract>();
                Map<Id, List<blng__Payment__c>> paymentsByContractId = new Map<Id, List<blng__Payment__c>> ();
                List<blng__Payment__c> allPayments = databaseInterface.queryPaymentsByRelatedContracts(contractIds);
                List<blng__Payment__c> paymentList = new List<blng__Payment__c>();
                for (blng__Payment__c payment : allPayments) {
                    if (paymentsByContractId.containsKey(payment.RelatedContract__c)) { 
                        paymentList = paymentsByContractId.get(payment.RelatedContract__c);
                    } 
                    else {
                        paymentList = new List<blng__Payment__c>();
                    }
                    paymentList.add(payment);
                    paymentsByContractId.put(payment.RelatedContract__c, paymentList);
                }
                
                Map<Id, Contract> contractsByIds = databaseInterface.queryContractsById(contractIds);
                if(!contractsByIds.isEmpty()){
                for (Id contractId : contractsByIds.keySet()) {
                    Contract contract = contractsByIds.get(contractId);
                    if(paymentsByContractId.get(contractId)  !=Null){
                    paymentList = paymentsByContractId.get(contractId);
                    }
                    Double totalAmount = 0;
                    for (blng__Payment__c payment : paymentList) {
                        totalAmount += payment.blng__Amount__c;
                    }
                    contract.Payments__c = totalAmount;
                    updateContracts.add(contract);
                }
                }
                if (updateContracts.size() > 0) {
                    databaseInterface.updateContracts(updateContracts);
                }
            }
        }
    
        /**
         * @description private InvoiceWrapper implements class
         */
        private class InvoiceWrapper implements Comparable {
            public blng__Invoice__c inv;
            public InvoiceWrapper(blng__Invoice__c anInvoice) {
                inv = anInvoice;
            }
            /**
             * @description
             * @param  compareTo Object compareTo
             * @return           integer
             */
            public Integer compareTo(Object compareTo) {
                InvoiceWrapper compareToInvoice = (InvoiceWrapper) compareTo;
                Integer returnValue = 0;
                if (inv.Schedule_Number__c > compareToInvoice.inv.Schedule_Number__c) {returnValue = 1;
                } else if (inv.Schedule_Number__c < compareToInvoice.inv.Schedule_Number__c) { returnValue = -1;
                }
                return returnValue;
            }
        }
    
        /**
         * @description Interface for the database interactions.
         */
    
        public interface PaymentHandlerDatabaseInterface {
            /**
             * @description apex variable.
             * @param  invoiceIds    List of invoice Ids
             * @param  invoiceStatus List of invoice status
             * @return               Map of Invoice
             */
            Map<Id, blng__Invoice__c> queryInvoiceByIdAndStatus(List<Id> invoiceIds, List<String> invoiceStatus);
    
            /**
             * @description apex variable.
             * @param  invoiceIds set of invoice id
             * @return            List of invoice
             */
            List<blng__InvoiceLine__c> queryInvoiceLinesByInvoiceId(Set<Id> invoiceIds);
    
            /**
             * @description apex variable.
             * @param  orderIds      List of order ids.
             * @param  invoiceStatus List of invoice status
             * @return               Map of Invoice
             */
            Map<Id, blng__Invoice__c> queryInvoiceByOrderIdAndStatus(List<Id> orderIds, List<String> invoiceStatus);
    
            /**
             * @description apex variable.
             * @param  paymentIds Set of payment ids
             * @return            Map of blng__PaymentAllocationInvoice__c
             */
            Map<Id, blng__PaymentAllocationInvoice__c> queryPaymentAllocationInvoiceByPaymentId(Set<Id> paymentIds);
    
            /**
             * @description apex variable.
             * @param  scheduleNumber Integer ScheduleNumber
             * @param  invoiceRuns    List of invoice status
             * @return                List of invoice
             */
            List<blng__Invoice__c> queryInvoicesByScheduleNumberAndInvoiceRun(Integer scheduleNumber, List<Id> invoiceRuns);
    
            /**
             * @description apex variable.
             * @param  balanceEqualAmount booleanbalanceAmount
             * @param  accountIds         set of account id's
             * @return                    List of payment
             */
            List<blng__Payment__c> queryPaymentsByBalanceEqualAmountAndAccounts(Boolean balanceEqualAmount, Set<Id> accountIds);
    
            /**
             * @description apex variable.
             * @param  relatedContractIds Set of id
             * @return                    List of payment
             */
            List<blng__Payment__c> queryPaymentsByRelatedContracts(Set<Id> relatedContractIds);
    
            /**
             * @description apex variable.
             * @param  contractIds set of contract id
             * @return             Map of id and contract
             */
            Map<Id, Contract> queryContractsById(Set<Id> contractIds);
    
            /**
             * @description apex variable.
             * @param  payment payment object
             * @return         decimal
             */
            Decimal getPaymentBalance(blng__Payment__c payment);
    
            /**
             * @description apex variable.
             * @param  invoice invoice object
             * @return         decimal
             */
            Decimal getInvoiceBalance(blng__Invoice__c invoice);
    
            /**
             * @description apex variable.
             * @param paymentAllocationInvoices List of payment
             */
            void insertPaymentAllocationInvoice(List<blng__PaymentAllocationInvoice__c> paymentAllocationInvoices);
    
            /**
             * @description apex variable.
             * @param updatePayments List of payment
             */
            void updatePayments(List<blng__Payment__c> updatePayments);
    
            /**
             * @description apex variable.
             * @param updateContracts List of contract
             */
            void updateContracts(List<Contract> updateContracts);
        }
    
        /**
         * @description Default SF Implementation for the database interface
         */
        public class PaymentHandlerDefaultDatabaseImpl implements PaymentHandler.PaymentHandlerDatabaseInterface {
            /**
             * @description apex variable.
             * @param  invoiceIds      List of invoice id
             * @param  invoiceStatuses List of invoice status
             * @return                 Map of invoice.
             */
            public Map<Id, blng__Invoice__c> queryInvoiceByIdAndStatus(List<Id> invoiceIds, List<String> invoiceStatuses) {
                return new Map<Id, blng__Invoice__c>([SELECT Id, blng__Order__c,
                                                      Schedule_Number__c, blng__Balance__c, First_Invoice__c
                                                      FROM blng__Invoice__c
                                                      WHERE Id IN :invoiceIds AND blng__InvoiceStatus__c IN :invoiceStatuses]);
            }
    
            /**
             * @description apex variable.
             * @param  invoiceIds Set of invoice id
             * @return            List of invoice line.
             */
            public List<blng__InvoiceLine__c> queryInvoiceLinesByInvoiceId(Set<Id> invoiceIds) {
                return [SELECT Id, blng__Invoice__c, blng__OrderProduct__r.OrderId
                        FROM blng__InvoiceLine__c
                        WHERE blng__Invoice__c IN :invoiceIds];
            }
    
            /**
             * @description apex variable.
             * @param  orderIds      List of order id.
             * @param  invoiceStatus List of invoice status
             * @return               Map of invoice
             */
            public Map<Id, blng__Invoice__c> queryInvoiceByOrderIdAndStatus(List<Id> orderIds, List<String> invoiceStatus) {
                return new Map<Id, blng__Invoice__c> ([SELECT Id, blng__Order__c,
                                                       Schedule_Number__c, blng__Balance__c, First_Invoice__c
                                                       FROM blng__Invoice__c
                                                       WHERE blng__Order__c IN :orderIds AND blng__InvoiceStatus__c IN :invoiceStatus]);
            }
    
            /**
             * @description apex variable.
             * @param  paymentIds set of payment
             * @return            Map of blng__PaymentAllocationInvoice__c
             */
            public Map<Id, blng__PaymentAllocationInvoice__c> queryPaymentAllocationInvoiceByPaymentId(Set<Id> paymentIds) {
                return new Map<Id, blng__PaymentAllocationInvoice__c>([SELECT Id, blng__Amount__c, blng__Invoice__c, blng__Payment__c, blng__Type__c, blng__Unallocated__c
                        FROM blng__PaymentAllocationInvoice__c
                        WHERE blng__Payment__c IN :paymentIds]);
            }
    
            /**
             * @description apex variable.
             * @param  scheduleNumber integer schedulenumber
             * @param  invoiceRuns    list of invoiceruns
             * @return                List of invoice
             */
            public List<blng__Invoice__c> queryInvoicesByScheduleNumberAndInvoiceRun(Integer scheduleNumber, List<Id> invoiceRuns) {
                return [SELECT Id, blng__Account__c, Schedule_Number__c, blng__Order__r.ContractId, CreatedDate
                        FROM blng__Invoice__c
                        WHERE Schedule_Number__c = :scheduleNumber AND blng__InvoiceRunCreatedBy__c IN :invoiceRuns
                                                   ORDER BY CreatedDate DESC];
            }
    
            /**
             * @description apex variable.
             * @param  balanceEqualAmount boolean Amount
             * @param  accountIds         Set of accountid
             * @return                    List of payment
             */
            public List<blng__Payment__c> queryPaymentsByBalanceEqualAmountAndAccounts(Boolean balanceEqualAmount, Set<Id> accountIds) {
                return [SELECT Id, blng__Account__c, blng__Balance__c, blng__Invoice__c, blng__Amount__c, Balance_Equal_Amount__c, RelatedContract__c
                        FROM blng__Payment__c
                        WHERE Balance_Equal_Amount__c = :balanceEqualAmount AND blng__Account__c IN :accountIds];
            }
    
            /**
             * @description apex variable.
             * @param  relatedContractIds set of id
             * @return                    list of payment
             */
            public List<blng__Payment__c> queryPaymentsByRelatedContracts(Set<Id> relatedContractIds) {
                return [SELECT Id, RelatedContract__c, blng__Amount__c FROM blng__Payment__c WHERE RelatedContract__c IN :relatedContractIds];
            }
    
            /**
             * @description apex variable.
             * @param  contractIds Set of id
             * @return             Map of contract
             */
            public Map<Id, Contract> queryContractsById(Set<Id> contractIds) {
                return new Map<Id, Contract> ([SELECT Id, Payments__c FROM Contract WHERE Id IN :contractIds]);
            }
    
            /**
             * @description apex variable.
             * @param  payment payment object
             * @return         decimal
             */
            public Decimal getPaymentBalance(blng__Payment__c payment) {
                return payment.blng__Balance__c;
            }
    
            /**
             * @description apex variable.
             * @param  invoice invoice object
             * @return         Decimal
             */
            public Decimal getInvoiceBalance(blng__Invoice__c invoice) {
                return invoice.blng__Balance__c;
            }
    
            /**
             * @description apex variable.
             * @param paymentAllocationInvoices List of payment object
             */
            public void insertPaymentAllocationInvoice(List<blng__PaymentAllocationInvoice__c> paymentAllocationInvoices) {
                insert paymentAllocationInvoices;
            }
    
            /**
             * @description apex variable.
             * @param updatePayments List of payment object
             */
            public void updatePayments(List<blng__Payment__c> updatePayments) {
                update updatePayments;
            }
    
            /**
             * @description apex variable.
             * @param updateContracts List of contract
             */
            public void updateContracts(List<Contract> updateContracts) {
                update updateContracts;
            }
        }
    }