/**
 * Scheduable for the CancelRebillInvoicesBatchable class
 */

global class CancelRebillInvoicesScheduableUSD implements Schedulable {
    global void execute(SchedulableContext sc) {

        CancelRebillInvoicesBatch batchJob = new CancelRebillInvoicesBatch(false, 0, 'USD');
        Id batchJobId = Database.executeBatch(batchJob, CancelRebillInvoicesBatch.BATCH_SIZE);
        System.debug('CancelRebillInvoicesScheduable.execute() id: ' + batchJobId);
    }
}