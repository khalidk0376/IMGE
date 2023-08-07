/**
 * Created/Modified By: Girikon(Archit, Aishwarya)
 * Created On:          11/07/2017
 * Description/Purpose: To create records on Event_Edition_Email_Template__c for all the current active events when a record for 
                        global Email_Template__c is created
 **/
trigger trgCreateEEEmailTempRecordOnEmailTemplate on Email_Templates__c (after insert) 
{
    triggersHandler handler = new triggersHandler();
    handler.CreateEEEmailTempRecordOnEmailTemplate(Trigger.New); // Call the handler class
}