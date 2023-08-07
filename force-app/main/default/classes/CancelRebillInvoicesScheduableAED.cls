/**
 * Scheduable for the CancelRebillInvoicesBatchable for UAE Durham
 * Code reverted by Rajesh Kumar - 8595 0n 24-11-2020
 */

global class CancelRebillInvoicesScheduableAED implements Schedulable {
    global void execute(SchedulableContext sc) {
        CancelRebillInvoicesBatch batchJob = new CancelRebillInvoicesBatch(false, 0, 'AED');
        Id batchJobId = Database.executeBatch(batchJob, CancelRebillInvoicesBatch.BATCH_SIZE);
    }
}