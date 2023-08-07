/**
 * Created/Modified By: Girikon(Aishwarya)
 * Created On:          12/21/2017
 * Modified On:         06/04/2018
 * Description/Purpose: This class is called through the SKUID page: Manual_List
 *                      This Class is for sending mass email reminder for the Manuals
 * Methods:             MassManualReminderEmail
 * Test Class:          MassManualReminderEmail_Test(100%)
 * Ticket No:           BK-14521 Updating API Version
**/

global class MassManualReminderEmail{
    webservice static boolean manualReminderNotification(String eventEditionId) { 
        MassManualReminderEmailBatch batch = new MassManualReminderEmailBatch(eventEditionId);
        Database.executeBatch(batch, 10);
        return true;
    }
}