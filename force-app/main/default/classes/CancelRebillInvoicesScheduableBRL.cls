/**
 * Scheduable for the CancelRebillInvoicesBatchable for Brazilian Real 
 * Code reverted by Rajesh Kumar - 8595 0n 24-11-2020
 */

global class CancelRebillInvoicesScheduableBRL implements Schedulable {
    global void execute(SchedulableContext sc) {
        CancelRebillInvoicesBatch batchJob = new CancelRebillInvoicesBatch(false, 0, 'BRL');
        Id batchJobId = Database.executeBatch(batchJob, CancelRebillInvoicesBatch.BATCH_SIZE);
    }
}