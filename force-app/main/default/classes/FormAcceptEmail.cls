/**
 * Created/Modified By: Girikon(Aish)
 * Created On:          06/07/2018 
 * Description/Purpose: This class is called through the SKUID page: UserFormActionReportFilled
 *                      This Class is for sending accept confirmation email
 * Methods:             FormAcceptEmail
 * Test Class:          FormAcceptEmail_Test(100%)
**/
global class FormAcceptEmail{
    webservice static boolean FormAcceptEmail(String eventEditionId, String userActionId, String EventEditionForm, String appprovalNote)
    { 
        FormAcceptEmailBatch batch = new FormAcceptEmailBatch(eventEditionId, userActionId, EventEditionForm, appprovalNote);
        Database.executeBatch(batch, 10);
        return true;
    }
}