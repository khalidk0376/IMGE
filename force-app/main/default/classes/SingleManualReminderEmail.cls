/**
 * Created/Modified By: Girikon(Aishwarya), Girikon(Amish)
 * Created On:          12/21/2017
 * Description/Purpose: This class is called through the SKUID page: UserFormActionReportFilled. 
 *                      This Class is for sending single email reminder.
 * Methods:             SingleManualReminderEmail
 * Test Class:          SingleManualReminderEmail_Test
 * Ticket No          : BK-14521 Updating API Version
**/

global class SingleManualReminderEmail{
    webservice static boolean singleManualReminderNotification(String eventEditionId,String accList , String EventEditionManual) {
        SingleManualReminderEmailBatch batch = new SingleManualReminderEmailBatch(eventEditionId, accList , EventEditionManual);
        Database.executeBatch(batch,10);
        return true;
    }
}