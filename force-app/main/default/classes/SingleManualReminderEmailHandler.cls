/**
 * Created/Modified By: Girikon(Aishwarya)
 * Created On:          8/1/2017
 * Description/Purpose: This Class is used for sending the single Manual reminder email and is call by the class - SingleManualReminderEmailBatch
 * Methods:             SingleManualReminderEmail
 * Test Class:          SingleManualReminderEmailHandler_Test(100%)
**/

global class SingleManualReminderEmailHandler{
    webservice static boolean SingleManualReminderEmail(String eventEditionId,String conList, String EventEditionManual) 
    { 
        
        List<String> cList= new  List<String>();
        cList=(List<String>) System.JSON.deserialize(conList, List<String>.class);
        system.debug(cList);
        List<Contact>contactList = [Select Email, Id, Name, AccountId from Contact where id=:cList];
        //List<User> usList = [select Email, id, Name,ContactId from User where ContactId=: cList];
        //system.debug(usList);
        List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c >();
        string tempContent = '';
        String tempSubject='';
        system.debug(eventEditionId);
        if(string.isNotBlank(eventEditionId))
        {
            eeeTemplateList = [Select Id, Name, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c from Event_Edition_Email_Template__c where Event_Edition__c =:eventEditionId AND Email_Template_Code__c ='MASIRM'];                 
            system.debug(eeeTemplateList );
        } 
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
                    //tempContent = eeeTemplateList[0].Content__c.replaceAll('\\{User.Name\\}',contactList[i].Name);
                    tempContent = eeeTemplateList[0].Content__c.replaceAll('\\{Number_of_agreed\\}','');
                    tempContent = tempContent.replaceAll('\\{Number_of_Assigned\\}','');
                    tempContent= ParsePlaceholders.renderTemplate(tempContent ,eeeTemplateList[0].Event_Edition__c,contactList[i].id);
                    tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, contactList[i].AccountId); 
                    tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, EventEditionManual);
                    //tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, '0010n000003gM5d');
                   // tempSubject = ParsePlaceholders.renderTemplate(eeeTemplateList[0].Subject__c,eeeTemplateList[0].Event_Edition__c);                   
                    tempSubject = ParsePlaceholders.renderTemplate(eeeTemplateList[0].Subject__c ,eeeTemplateList[0].Event_Edition__c,contactList[i].id);
                    tempSubject = ParsePlaceholders.renderTemplate(tempSubject ,eeeTemplateList[0].Event_Edition__c,contactList[i].AccountId);
                    tempSubject = ParsePlaceholders.renderTemplate(tempSubject ,eeeTemplateList[0].Event_Edition__c,EventEditionManual);
                    system.debug('tempContent==='+tempContent);
                }
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] {contactList[i].email});           
                email.setSaveAsActivity(false);
                email.setTargetObjectId(contactList[i].Id); 
                email.setHtmlBody(tempContent);
                //email.setSubject(eeeTemplateList[0].Subject__c);
                email.setSubject(tempSubject);       
                massEmailLst.Add(email);
   
        }       
        system.debug('massEmailLst==='+massEmailLst);
        Messaging.sendEmail(massEmailLst);
                
        return true;
    }
}

/*global class SingleManualReminderEmail{
    webservice static boolean SingleManualReminderEmail(String eventEditionId,String conList, String EventEditionManual) 
    { 
        
        List<String> cList= new  List<String>();
        cList=(List<String>) System.JSON.deserialize(conList, List<String>.class);
        system.debug(cList);
        List<Contact>contactList = [Select Email, Id, Name from Contact where id=:cList];
        //List<User> usList = [select Email, id, Name,ContactId from User where ContactId=: cList];
        //system.debug(usList);
        List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c >();
        string tempContent = '';
        system.debug(eventEditionId);
        if(string.isNotBlank(eventEditionId))
        {
            eeeTemplateList = [Select Id, Name, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c from Event_Edition_Email_Template__c where Event_Edition__c =:eventEditionId AND Email_Template_Code__c ='MASIRM'];                 
            system.debug(eeeTemplateList );
        } 
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
                    //tempContent = eeeTemplateList[0].Content__c.replaceAll('\\{User.Name\\}',contactList[i].Name);
                    tempContent= ParsePlaceholders.renderTemplate(eeeTemplateList[0].Content__c,eeeTemplateList[0].Event_Edition__c,contactList[i].id);
                    tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, EventEditionManual);
                    //tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, '0010n000003gM5d');
                    system.debug('tempContent==='+tempContent);
                }
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
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
}*/