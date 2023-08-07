/**
 * Scheduable for the CancelRebillInvoicesBatchable class for EUR
 */


public class CancelRebillInvoicesScheduableEUR implements Schedulable {

    public void execute(SchedulableContext sc) {

        CancelRebillInvoicesBatch batchJob = new CancelRebillInvoicesBatch(false, 0, 'EUR');
        Id batchJobId = Database.executeBatch(batchJob, CancelRebillInvoicesBatch.BATCH_SIZE);
        System.debug('CancelRebillInvoicesScheduableEUR.execute() id: ' + batchJobId);
    }
}