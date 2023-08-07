/**
 * Created/Modified By: Girikon(Amish)
 * Created On:          8/9/2017
 * Description/Purpose: This class is used for sending the reminder email for badges
 * Methods:             BadgesReminderEmail
 * Test Class:          BadgesReminderEmail_Test

* Modification Log----- 
* Modified by : Girikon(Mahesh)[CCEN-358],
* Modified On: 10/22/2018
 **/
global class BadgesReminderEmail{
    webservice static boolean BadgesReminderEmail(String eventEditionId,String conList, String EventEditionForm) 
    { 
        
        List<String> cList= new  List<String>();
        cList=(List<String>) System.JSON.deserialize(conList, List<String>.class);
        system.debug(cList);
        List<Contact>contactList = [Select Email, Id, Name from Contact where id=:cList];
        /*List<User> usList = [select Email, id, Name,ContactId from User where ContactId=: cList];
        system.debug(usList);*/
        List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c >();
        string tempContent = '';
        system.debug(eventEditionId);
        if(string.isNotBlank(eventEditionId))
        {
            eeeTemplateList = [Select Id, Name,From_Email_Address__r.Org_Wide_From_Email_Addresses__c, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c from Event_Edition_Email_Template__c where Event_Edition__c =:eventEditionId AND Email_Template_Code__c ='FO0003'];                 
        } 
        String fromAdd;
        //added this functionality regarding ticket [CCEN-358]
        if(eeeTemplateList!=null && !eeeTemplateList.IsEmpty())
        {
         fromAdd = eeeTemplateList[0].From_Email_Address__r.Org_Wide_From_Email_Addresses__c;      
        } 
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:fromAdd];  

        system.debug(eeeTemplateList );
        List<Messaging.SingleEmailMessage> massEmailLst= new List<Messaging.SingleEmailMessage>();
        //system.debug( conList );                           
        for (integer i=0;i<contactList.size();i++)
        {
            //system.debug(exhibitorIDList.size());
           
                system.debug('Email==='+contactList[i].email);
                //system.debug('Email==='+u.Name);
                if(eeeTemplateList!=null && eeeTemplateList.size()>0)
                {   
                    tempContent = eeeTemplateList[0].Content__c.replaceAll('\\{User.Name\\}',contactList[i].Name);
                    tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, EventEditionForm);
                    //tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, '0010n000003gM5d');
                    system.debug('tempContent==='+tempContent);
                }
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                //added this functionality regarding ticket [CCEN-358]
                if(!owea.isEmpty() && owea.size()>0)
                 {
                   email.setOrgWideEmailAddressId(owea.get(0).Id);
                 }
                email.setToAddresses(new String[] {contactList[i].email});           
                email.setSaveAsActivity(false);
                email.setTargetObjectId(contactList[i].Id); 
                email.setHtmlBody(tempContent);
                email.setSubject(eeeTemplateList[0].Subject__c);     
                massEmailLst.Add(email);
   
        }       
        system.debug('massEmailLst==='+massEmailLst);
        Messaging.sendEmail(massEmailLst);
                
        return true;
    }
}