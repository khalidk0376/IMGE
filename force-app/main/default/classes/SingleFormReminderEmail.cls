/**
 * Created/Modified By: Girikon(Aishwarya)
 * Created On:          12/21/2017
 * Description/Purpose: This class is called through the SKUID page: UserFormActionReportFilled. 
 *                      This Class is for sending single email reminder which will call the batch class - SingleFormReminderEmailBatch
 * Methods:             SingleFormReminderEmail
 * Test Class:          SingleFormReminderEmail_Test
 * Ticket No          : BK-14521 Updating API Version
**/

global class SingleFormReminderEmail{
    webservice static boolean reminderEmailNotification(String eventEditionId, String accList, String EventEditionForm)
    { 
        SingleFormReminderEmailBatch batch = new SingleFormReminderEmailBatch(eventEditionId, accList, EventEditionForm);
        Database.executeBatch(batch,10);
        return true;
    }
}