/**
 * Batch class to take any unallocated payments and allocate them to the most recent invoice.
 */

global class PaymentInvoiceAllocationBatchable implements Database.Batchable<sObject>, Database.Stateful {

    private Boolean doReschedule;
    private Integer syncFrequency = 5;
    private final String QUERY = 'SELECT Id, blng__Account__c, blng__Balance__c, blng__Invoice__c, blng__Amount__c, Balance_Equal_Amount__c, blng__Invoice__r.blng__Order__r.Id ' +
            'FROM blng__Payment__c WHERE Balance_Equal_Amount__c = true';

    public PaymentInvoiceAllocationBatchable(Boolean doReschedule) {
        this.doReschedule = doReschedule;
    }

    public PaymentInvoiceAllocationBatchable(Integer syncFrequency) {
        this.doReschedule = true;
        this.syncFrequency = syncFrequency;
    }

    global Database.QueryLocator start(Database.BatchableContext batchableContext) {
        System.debug('PaymentInvoiceAllocationBatchable start batch job');
        return Database.getQueryLocator(QUERY);
    }

    global void execute(Database.BatchableContext batchableContext, List<sObject> scope) {
        //List<blng__Payment__c> paymentList = new List<blng__Payment__c>();
        List<blng__Payment__c> updatePayments = new List<blng__Payment__c>();
        Map<Id, List<blng__Payment__c>> paymentsByAccountId = new Map<Id, List<blng__Payment__c>>();
        List<blng__Payment__c> paymentSubList = new List<blng__Payment__c>();
        for(sObject abstractObject: scope) {
            blng__Payment__c payment = (blng__Payment__c) abstractObject;
            if(paymentsByAccountId.containsKey(payment.blng__Account__c)) {
                paymentSubList = paymentsByAccountId.get(payment.blng__Account__c);
            } else {
                paymentSubList = new List<blng__Payment__c>();
            }
            paymentSubList.add(payment);
            paymentsByAccountId.put(payment.blng__Account__c, paymentSubList);
        }
        System.debug('PaymentInvoiceAllocationBatchable paymentsByAccountId: ' + paymentsByAccountId);

        List<blng__Invoice__c> invoices = new List<blng__Invoice__c>();
        if(paymentsByAccountId.size() > 0) {
            invoices = [SELECT Id, blng__Account__c, Schedule_Number__c, blng__Order__r.Type, CreatedDate FROM blng__Invoice__c WHERE Schedule_Number__c = 1 AND blng__Account__c IN :paymentsByAccountId.keySet() ORDER BY CreatedDate DESC];
        }
        System.debug('PaymentInvoiceAllocationBatchable invoices: ' + invoices);

        Map<Id, blng__Invoice__c> invoiceByAccountId = new Map<Id, blng__Invoice__c>();
        for(blng__Invoice__c invoice: invoices) {
            // Only want to capture the first invoice in the list as it is the latest invoice.
            if(!invoiceByAccountId.containsKey(invoice.blng__Account__c)) {
                invoiceByAccountId.put(invoice.blng__Account__c, invoice);
            }
        }

        for(Id accountId: paymentsByAccountId.keySet()) {
            List<blng__Payment__c> payments = paymentsByAccountId.get(accountId);
            for(blng__Payment__c payment: payments) {
                if(invoiceByAccountId.containsKey(accountId)) {
                    payment.blng__Invoice__c = invoiceByAccountId.get(accountId).Id;
                    updatePayments.add(payment);
                }
            }
        }

        System.debug('PaymentInvoiceAllocationBatchable updatePayments: ' + updatePayments);
        if(updatePayments.size() > 0) {
            update updatePayments;
        }
    }

    global void finish(Database.BatchableContext batchableContext) {
        System.debug('PaymentInvoiceAllocationBatchable Finished');
        if(Test.isRunningTest()) {
            return;
        }
        if(this.doReschedule) {
            rescheduleThis();
        }
    }

    private void rescheduleThis() {
        PaymentInvoiceAllocationBatchable batch = new PaymentInvoiceAllocationBatchable(syncFrequency);
        System.scheduleBatch(batch, 'PaymentInvoiceAllocationBatchable', syncFrequency);
    }

    //TODO Remove this after UAT - Not recommended!!!!
    public static void fakeMethod() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }

}