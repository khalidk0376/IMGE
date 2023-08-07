/**
 * Scheduable for the JournalBatch process.
 */

public class JournalBatchScheduable implements Schedulable {
    public void execute(SchedulableContext sc) {
        JournalBatch batchJob = new JournalBatch(false, 60);
        Id batchJobId = Database.executeBatch(batchJob);
        System.debug('JournalBatchScheduable.execute() id: ' + batchJobId);
    }
}