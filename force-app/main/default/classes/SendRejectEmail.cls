/**
 * Created/Modified By: Girikon(Amish)
 * Created On:          6/16/2017
 * Description/Purpose: This class is called through the SKUID page: UserFormActionReportFilled. 
 *                      This Class is for sending form reject email.
 * Methods:             sendRejectEmail
 * Test Class:          SendRejectEmail_Test
**/

global class SendRejectEmail{
    webservice static boolean sendRejectEmailNotification(String FormUserActionId,string Type) 
    { 
        List <User_Form_Action__c> formData= [SELECT id,name ,User_Form_Contact__c from User_Form_Action__c where ID =: FormUserActionId limit 1]; 
        List<Contact> con = [SELECT Id, name from Contact where id=:formData[0].User_Form_Contact__c]; 
        system.debug(FormUserActionId);                      
        if(!formData.IsEmpty())
        {
             EmailTemplate et=[Select id,name from EmailTemplate where name='Test Template' limit 1];
             Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();           
             mail.setTargetObjectId(con[0].id);
             mail.setSenderDisplayName('Opeartaion Admin');
             mail.setTemplateId(et.id);
             Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } 
        return true;
    }
}