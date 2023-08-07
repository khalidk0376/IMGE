/**
 * Created/Modified By: Girikon(Aishwarya)
 * Created On:          12/21/2017
 * Description/Purpose: This class is called through the SKUID page: EventEditionFormList
 *                      This Class is for sending mass email reminder.
 * Methods:             MassFormReminderEmail
 * Test Class:          MassFormReminderEmail_Test(100%)
 * Ticket No:           BK-14521 Updating API Version
**/

global class MassFormReminderEmail{
    webservice static boolean massFormEmailNotification(String eventEditionId)
    { 
        MassFormReminderEmailBatch batch = new MassFormReminderEmailBatch(eventEditionId);
        Database.executeBatch(batch, 10);
        return true;
    }
}