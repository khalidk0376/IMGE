/**
 * Created/Modified By: Girikon(Amish)
 * Created On:          7/13/2017
 * Description/Purpose: This Class is for sending single email for accepting and rejecting badge from Ops portal
 * Methods:             SingleBadgeEmail
 * Test Class:          SingleBadgeEmail_Test
**/

global class SingleBadgeEmail{
    webservice static boolean sendSingleBadgeEmail(String eventEditionId,String conID, String ExhibitorBadgeID,String emailType, String Note) 
    { 
        List<Contact> conList = [select Email, id, Name, AccountId from Contact where id =: conID];
        //List<User> userList = [select Email, id, Name from User where id =: User];
        List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c >();
        string tempContent = '';
        String tempSubject=''; 
        if(string.isNotBlank(eventEditionId))
        {
            if (emailType=='Reject')
            {
                eeeTemplateList = [Select Id, Name, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c 
                                        from Event_Edition_Email_Template__c where Event_Edition__c =:eventEditionId AND Email_Template_Code__c = 'BDGREJ'];
            }
            if (emailType=='Approve')
            {
                eeeTemplateList = [Select Id, Name, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c 
                                        from Event_Edition_Email_Template__c where Event_Edition__c =:eventEditionId AND Email_Template_Code__c = 'BDGAPR'];
            }
            
        } 
        List<Messaging.SingleEmailMessage> massEmailLst= new List<Messaging.SingleEmailMessage>();
        //system.debug( conList );                           
        for(Contact c: conList )
        {
            system.debug('Email==='+c.email);
            system.debug('Email==='+c.Name);
            if(eeeTemplateList!=null && eeeTemplateList.size()>0)
            {   
                //tempContent = eeeTemplateList[0].Content__c.replaceAll('\\{User.Name\\}',c.name);
                tempContent= ParsePlaceholders.renderTemplate(eeeTemplateList[0].Content__c,eeeTemplateList[0].Event_Edition__c,c.id);
                tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, ExhibitorBadgeID);
                tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, c.AccountId);
                system.debug('tempContent==='+tempContent);
                tempSubject = ParsePlaceholders.renderTemplate(eeeTemplateList[0].Subject__c,eeeTemplateList[0].Event_Edition__c,c.Id);
                tempSubject = ParsePlaceholders.renderTemplate(tempSubject ,eeeTemplateList[0].Event_Edition__c,ExhibitorBadgeID);                  
                tempSubject = ParsePlaceholders.renderTemplate(tempSubject ,eeeTemplateList[0].Event_Edition__c,c.AccountId); 
            }
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] {c.email});           
            email.setSaveAsActivity(false);
            email.setTargetObjectId(c.Id); 
            email.setHtmlBody(tempContent+'[Note: '+Note+ ' ]');
           // email.setSubject(eeeTemplateList[0].Subject__c); 
            email.setSubject(tempSubject );    
            massEmailLst.Add(email);    
        }       
        system.debug('massEmailLst==='+massEmailLst);
        Messaging.sendEmail(massEmailLst);
                
        return true;
    }
}

/*global class SingleBadgeEmail{
    webservice static boolean SingleBadgeEmail(String eventEditionId,String conID, String ExhibitorBadgeID,String emailType, String Note) 
    { 
        List<Contact> conList = [select Email, id, Name from Contact where id =: conID];
        //List<User> userList = [select Email, id, Name from User where id =: User];
        List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c >();
        string tempContent = '';
        if(string.isNotBlank(eventEditionId))
        {
            if (emailType=='Reject')
            {
                eeeTemplateList = [Select Id, Name, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c 
                                        from Event_Edition_Email_Template__c where Event_Edition__c =:eventEditionId AND Email_Template_Code__c = 'BDGREJ'];
            }
            if (emailType=='Approve')
            {
                eeeTemplateList = [Select Id, Name, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c 
                                        from Event_Edition_Email_Template__c where Event_Edition__c =:eventEditionId AND Email_Template_Code__c = 'BDGAPR'];
            }
            
        } 
        List<Messaging.SingleEmailMessage> massEmailLst= new List<Messaging.SingleEmailMessage>();
        //system.debug( conList );                           
        for(Contact c: conList )
        {
            system.debug('Email==='+c.email);
            system.debug('Email==='+c.Name);
            if(eeeTemplateList!=null && eeeTemplateList.size()>0)
            {   
                //tempContent = eeeTemplateList[0].Content__c.replaceAll('\\{User.Name\\}',c.name);
                tempContent= ParsePlaceholders.renderTemplate(eeeTemplateList[0].Content__c,eeeTemplateList[0].Event_Edition__c,c.id);
                tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, ExhibitorBadgeID);
                system.debug('tempContent==='+tempContent);
            }
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] {c.email});           
            email.setSaveAsActivity(false);
            email.setTargetObjectId(c.Id); 
            email.setHtmlBody(tempContent+'[Note: '+Note+ ' ]');
            email.setSubject(eeeTemplateList[0].Subject__c);     
            massEmailLst.Add(email);    
        }       
        system.debug('massEmailLst==='+massEmailLst);
        Messaging.sendEmail(massEmailLst);
                
        return true;
    }
}*/