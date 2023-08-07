/**
 * Trigger on the blng__Payment__c class.
 */

trigger PaymentTrigger on blng__Payment__c (before insert, before update, after insert, after update, before delete, after delete, after undelete ) {
    System.debug('PaymentTrigger ');
    if(Trigger.isAfter) {
        PaymentHandler pmtHandler = new PaymentHandler();
        if(Trigger.isInsert) {
            pmtHandler.handlePaymentAllocations(Trigger.newMap);
            pmtHandler.rollupPaymentTotalsForContract(Trigger.newMap);
        }

        if(Trigger.isUpdate) {

            Map<Id, blng__Payment__c> paymentsInvoiceUpdated = new Map<Id, blng__Payment__c>();
            for(blng__Payment__c payment: Trigger.new) {
                if(payment.blng__Invoice__c != Trigger.oldMap.get(payment.Id).blng__Invoice__c){
                    paymentsInvoiceUpdated.put(payment.Id, payment);
                }
            }

            if(paymentsInvoiceUpdated.size() > 0) {
                pmtHandler.handlePaymentAllocations(paymentsInvoiceUpdated);
            }
            pmtHandler.rollupPaymentTotalsForContract(Trigger.newMap);
        }

        if(Trigger.isDelete) {
            pmtHandler.rollupPaymentTotalsForContract(Trigger.oldMap);
        }

        if(Trigger.isUndelete) {
            pmtHandler.rollupPaymentTotalsForContract(Trigger.newMap);
        }
    }
}