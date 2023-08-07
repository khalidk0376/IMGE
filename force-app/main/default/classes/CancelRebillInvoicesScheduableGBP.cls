/**
 * Scheduable for the CancelRebillInvoicesBatchable class for GBP
 */

global class CancelRebillInvoicesScheduableGBP implements Schedulable {
    global void execute(SchedulableContext sc) {

        CancelRebillInvoicesBatch batchJob = new CancelRebillInvoicesBatch(false, 0, 'GBP');
        Id batchJobId = Database.executeBatch(batchJob, CancelRebillInvoicesBatch.BATCH_SIZE);
        System.debug('CancelRebillInvoicesScheduable.execute() id: ' + batchJobId);
    }
}