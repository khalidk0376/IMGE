/**
 * Created/Modified By: Girikon(Aishwary)
 * Created On:          7/18/2017 
 * Description/Purpose: This class is called through the SKUID page: UserFormActionReportFilled. 
 *                      This Class is for sending single email reminder.
 * Methods:             SingleFormReminderEmail
 * Test Class:          SingleFormReminderEmailHandler_Test(100%)
**/

public class SingleFormReminderEmailHandler{
    public static boolean SingleFormReminderEmail(String eventEditionId,String conList, String EventEditionForm) 
    { 
        
        List<String> cList= new  List<String>();
        cList=(List<String>) System.JSON.deserialize(conList, List<String>.class);
        system.debug(cList);
        List<Contact>contactList = [Select Email, Id, Name,AccountId from Contact where id=:cList];
        //List<User> usList = [select Email, id, Name,ContactId from User where ContactId=: cList];
        //system.debug(usList);
        List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c >();
        string tempContent = '';
        String tempSubject= '';
        system.debug(eventEditionId);
        if(string.isNotBlank(eventEditionId))
        {
            eeeTemplateList = [Select Id, Name, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c from Event_Edition_Email_Template__c where Event_Edition__c =:eventEditionId AND Email_Template_Code__c ='FOSIRM'];                 
        } 
        system.debug(eeeTemplateList );
        List<Messaging.SingleEmailMessage> massEmailLst= new List<Messaging.SingleEmailMessage>();
        system.debug( conList );                           
        for (integer i=0;i<contactList.size();i++)
        {
            //system.debug(exhibitorIDList.size());
           
                system.debug('Email==='+contactList[i].email);
                system.debug('id==='+contactList[i].id);
                //system.debug('Email==='+u.Name);
                if(eeeTemplateList!=null && eeeTemplateList.size()>0)
                {   ////
                    //tempSubject = ParsePlaceholders.renderTemplate(eeeTemplateList[0].Subject__c,eeeTemplateList[0].Event_Edition__c);
                    tempSubject = ParsePlaceholders.renderTemplate(eeeTemplateList[0].Subject__c,eeeTemplateList[0].Event_Edition__c,EventEditionForm);
                    tempSubject = ParsePlaceholders.renderTemplate(tempSubject ,eeeTemplateList[0].Event_Edition__c,contactList[i].Id);
                    tempSubject = ParsePlaceholders.renderTemplate(tempSubject ,eeeTemplateList[0].Event_Edition__c,contactList[i].AccountId);
                    system.debug('tempSubject ==='+tempSubject );
                    //tempContent = eeeTemplateList[0].Content__c.replaceAll('\\{Contact.Name\\}',contactList[i].Name); 
                    tempContent = eeeTemplateList[0].Content__c.replaceAll('\\{Number_of_Filled\\}','');
                    tempContent = tempContent.replaceAll('\\{Number_of_Assigned\\}','');                 
                    tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c,contactList[i].id);
                    tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, EventEditionForm);
                    tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, contactList[i].AccountId); 
                    system.debug('tempContent ==='+tempContent);              
                    
                }
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] {contactList[i].email});           
                email.setSaveAsActivity(false);
                email.setTargetObjectId(contactList[i].Id); 
                email.setHtmlBody(tempContent);
                //email.setSubject(eeeTemplateList[0].Subject__c);  
                email.setSubject(tempSubject);   
                massEmailLst.Add(email);
                email.setSubject(tempSubject);     
   
        }       
        system.debug('massEmailLst==='+massEmailLst);
        Messaging.sendEmail(massEmailLst);
                
        return true;
    }
}