/**
 * Created/Modified By: Girikon(Aish)
 * Created On:          06/07/2018 
 * Description/Purpose: This class is called through the SKUID page: UserFormActionReportFilled
 *                      This Class is for sending reject confirmation email
 * Methods:             FormRejectEmail
 * Test Class:          FormRejectEmail_Test(100%)
**/
global class FormRejectEmail{
    webservice static boolean FormRejectEmail(String eventEditionId, String userActionId, String EventEditionForm, String rejectionNote)
    { 
        FormRejectEmailBatch batch = new FormRejectEmailBatch(eventEditionId, userActionId, EventEditionForm, rejectionNote);
        Database.executeBatch(batch, 10);
        return true;
    }
}