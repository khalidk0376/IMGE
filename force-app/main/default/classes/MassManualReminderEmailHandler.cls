/**
 * Created/Modified By: Girikon(Amish, Aishwarya)
 * Created On:          8/2/2017
 * Description/Purpose: This Class is used for sending mass email reminder through batch class - MassManualReminderEmailBatch 
 * Methods:             MassManualReminderEmail
 * Test Class:          MassManualReminderEmailHandler_Test(100%)
**/

global class MassManualReminderEmailHandler{
   webservice static boolean MassManualReminderEmail(String eventEditionId,String uMAList) 
    {       
        List<String> uAList= new  List<String>();
        List<Event_Edition__c > eventName= [Select Id,Name from Event_Edition__c where id =: eventEditionId];
        uAList=(List<String>) System.JSON.deserialize(uMAList, List<String>.class);
        //system.debug(uAList);
        List<User_Manual_Action__c> userAMList = [select id, Name,Is_Agree__c,Manual_Permission__r.Manuals__r.Name, User_Manual_Contact__c from User_Manual_Action__c where Id IN: uAList];
        Set<Id> conId = new Set<Id>();
       // List<Id> conIdd = new List<Id>();
        for(User_Manual_Action__c uAM: userAMList )
        {
            conId.add(uAM.User_Manual_Contact__c );
            //conIdd.add(uAM.User_Manual_Contact__c );
        }
        //List<User> usList = [select Email, id, Name,ContactId from User where ContactId=: conId];
        List<Contact> conList = [select Email, id, Name,AccountId from Contact where Id=: conId];
               
        List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c >();
        string tempContent = '';
        String tempSubject='';       
        if(string.isNotBlank(eventEditionId))
        {
            eeeTemplateList = [Select Id, Name, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c from Event_Edition_Email_Template__c where Event_Edition__c =:eventEditionId AND Email_Template_Code__c ='MAMSRM'];                 
        } 
        List<Messaging.SingleEmailMessage> massEmailLst= new List<Messaging.SingleEmailMessage>();       
        for (Contact con: conList) 
        { 
             List<String> tempManualList= new  List<String>();
             integer i = 0; 
             integer nonAgree=0;
             integer assign=0;  
             integer agree;     
             for(User_Manual_Action__c uAM: userAMList )
             {
                 
                 if (uAM.User_Manual_Contact__c ==con.Id)
                 {
                     assign++; 
                     if (uAM.Is_Agree__c!=true&&uAM.User_Manual_Contact__c ==con.Id )                 
                     {
                         //System.Debug(uAM.Manual_Permission__r.Manuals__r.Name +'/' +uId);
                         i++;
                         nonAgree++;                                                      
                         tempManualList.add(i+'.'+uAM.Manual_Permission__r.Manuals__r.Name);              
                     }
                 }
                 
             }
             agree = assign-nonAgree;
             String agreeed= String.valueOf(agree);
             String assigned= String.valueOf(assign);
             system.debug(agreeed);
             system.debug(assigned);


             string manuals='';
             for ( String tempMList: tempManualList)
             {
                 manuals=manuals+tempMList+'<br/>';               
             }    
            //system.debug('Email==='+uId.email);
            //system.debug('UName==='+uId.Name);
            // String userId= uId.id;
            // //system.debug(userId);
            if (tempManualList!=null && tempManualList.size()>0)
            {
                if(eeeTemplateList!=null && eeeTemplateList.size()>0 )
                {   
                    //tempContent = eeeTemplateList[0].Content__c.replaceAll('\\{User.Name\\}',uId.Name);
                    //tempContent = tempContent.replaceAll('\\{Manual__c.Name\\}',manuals);
                    tempContent = eeeTemplateList[0].Content__c.replaceAll('\\{Manual__c.Name\\}',manuals);
                    tempContent = tempContent.replaceAll('\\{Number_of_agreed\\}',agreeed);
                    tempContent = tempContent.replaceAll('\\{Number_of_Assigned\\}',assigned);
                    //system.debug(tempContent );
                    tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, eventEditionId);
                    tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c,con.Id);
                    tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c,con.AccountId);
                    //system.debug('tempContent==='+tempContent);
                    //tempSubject = eeeTemplateList[0].Subject__c.replaceAll('\\{Event_Edition__c.Name\\}',eventName[0].Name);
                    //tempSubject = ParsePlaceholders.renderTemplate(eeeTemplateList[0].Subject__c,eeeTemplateList[0].Event_Edition__c);
                    tempSubject = eeeTemplateList[0].Subject__c.replaceAll('\\{Event_Edition__c.Name\\}',eventName[0].Name);
                    tempSubject = tempSubject.replaceAll('\\{Number_of_agreed\\}',agreeed);
                    tempSubject = tempSubject.replaceAll('\\{Number_of_Assigned\\}',assigned);
                    tempSubject = ParsePlaceholders.renderTemplate(tempSubject ,eeeTemplateList[0].Event_Edition__c, eventEditionId);
                    tempSubject = ParsePlaceholders.renderTemplate(tempSubject ,eeeTemplateList[0].Event_Edition__c,con.Id);
                    tempSubject = ParsePlaceholders.renderTemplate(tempSubject ,eeeTemplateList[0].Event_Edition__c,con.AccountId);    
                    
                }
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] {con.email});           
                email.setSaveAsActivity(false);
                email.setTargetObjectId(con.Id); 
                email.setHtmlBody(tempContent);
                email.setSubject(tempSubject);     
                massEmailLst.Add(email);  
                system.debug(massEmailLst);
            }                       
        }
        system.debug('massEmailLst==='+massEmailLst);
        if (massEmailLst!=null && massEmailLst.size()>0)
        {
            Messaging.sendEmail(massEmailLst);
        }
               
        return true;
    }
}


/*global class MassManualReminderEmail{
   webservice static boolean MassManualReminderEmail(String eventEditionId,String uMAList) 
    {       
        List<String> uAList= new  List<String>();
        List<Event_Edition__c > eventName= [Select Id,Name from Event_Edition__c where id =: eventEditionId];
        uAList=(List<String>) System.JSON.deserialize(uMAList, List<String>.class);
        //system.debug(uAList);
        List<User_Manual_Action__c> userAMList = [select id, Name,Is_Agree__c,Manual_Permission__r.Manuals__r.Name, User_Manual_Contact__c from User_Manual_Action__c where Id IN: uAList];
        Set<Id> conId = new Set<Id>();
       // List<Id> conIdd = new List<Id>();
        for(User_Manual_Action__c uAM: userAMList )
        {
            conId.add(uAM.User_Manual_Contact__c );
            //conIdd.add(uAM.User_Manual_Contact__c );
        }
        List<User> usList = [select Email, id, Name,ContactId from User where ContactId=: conId];               
               
        List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c >();
        string tempContent = '';
        String tempSubject='';       
        if(string.isNotBlank(eventEditionId))
        {
            eeeTemplateList = [Select Id, Name, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c from Event_Edition_Email_Template__c where Event_Edition__c =:eventEditionId AND Email_Template_Code__c ='MAMSRM'];                 
        } 
        List<Messaging.SingleEmailMessage> massEmailLst= new List<Messaging.SingleEmailMessage>();       
        for (User uId: usList) 
        { 
             List<String> tempManualList= new  List<String>();
             integer i = 0; 
             integer nonAgree=0;
             integer assign=0;  
             integer agree;     
             for(User_Manual_Action__c uAM: userAMList )
             {
                 
                 if (uAM.User_Manual_Contact__c ==uId.ContactId)
                 {
                     assign++; 
                     if (uAM.Is_Agree__c!=true&&uAM.User_Manual_Contact__c ==uId.ContactId )                 
                     {
                         //System.Debug(uAM.Manual_Permission__r.Manuals__r.Name +'/' +uId);
                         i++;
                         nonAgree++;                                                      
                         tempManualList.add(i+'.'+uAM.Manual_Permission__r.Manuals__r.Name);              
                     }
                 }
                 
             }
             agree = assign-nonAgree;
             String agreeed= String.valueOf(agree);
             String assigned= String.valueOf(assign);
             system.debug(agreeed);
             system.debug(assigned);


             string manuals='';
             for ( String tempMList: tempManualList)
             {
                 manuals=manuals+tempMList+'<br/>';               
             }    
            //system.debug('Email==='+uId.email);
            //system.debug('UName==='+uId.Name);
            // String userId= uId.id;
            // //system.debug(userId);
            if (tempManualList!=null && tempManualList.size()>0)
            {
                if(eeeTemplateList!=null && eeeTemplateList.size()>0 )
                {   
                    //tempContent = eeeTemplateList[0].Content__c.replaceAll('\\{User.Name\\}',uId.Name);
                    //tempContent = tempContent.replaceAll('\\{Manual__c.Name\\}',manuals);
                    tempContent = eeeTemplateList[0].Content__c.replaceAll('\\{Manual__c.Name\\}',manuals);
                    tempContent = tempContent.replaceAll('\\{Number_of_agreed\\}',agreeed);
                    tempContent = tempContent.replaceAll('\\{Number_of_Assigned\\}',assigned);
                    //system.debug(tempContent );
                    tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, eventEditionId);
                    tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c,uId.ContactId);
                    //system.debug('tempContent==='+tempContent);
                    //tempSubject = eeeTemplateList[0].Subject__c.replaceAll('\\{Event_Edition__c.Name\\}',eventName[0].Name);
                    tempSubject = ParsePlaceholders.renderTemplate(eeeTemplateList[0].Subject__c,eeeTemplateList[0].Event_Edition__c);
                    
                }
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] {uId.email});           
                email.setSaveAsActivity(false);
                email.setTargetObjectId(uId.Id); 
                email.setHtmlBody(tempContent);
                email.setSubject(tempSubject);     
                massEmailLst.Add(email);  
                system.debug(massEmailLst);
            }                       
        }
        system.debug('massEmailLst==='+massEmailLst);
        if (massEmailLst!=null && massEmailLst.size()>0)
        {
            Messaging.sendEmail(massEmailLst);
        }
               
        return true;
    }
}*/