/**
 * Trigger for the Invoice Run from the billing project.
 */
//Modofied By Rajesh Kumar - On 10-06-2020 on - BK-3756 test class : InvoiceRunTriggerTest
trigger InvoiceRunTrigger on blng__InvoiceRun__c (before insert, before update, after insert, after update) {
    InvoiceRunTrigger_handler.callPaymentHandler(Trigger.new, Trigger.oldMap,Trigger.isAfter,Trigger.isUpdate);
}