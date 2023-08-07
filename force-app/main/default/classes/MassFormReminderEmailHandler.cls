/**
 * Created/Modified By: Girikon(Amish, Aishwarya)
 * Created On:          7/18/2017
 * Description/Purpose: This class is called through the batch class: MassFormReminderEmailBatch
 * Methods:             MassFormReminderEmail
 * Test Class:          MassFormReminderEmailHandler_Test(96%)
**/

global class MassFormReminderEmailHandler{
   webservice static boolean MassFormReminderEmail(String eventEditionId,String uFAList) 
    {   
        system.debug(eventEditionId);     
        List<String> uAList= new  List<String>();
        List<Event_Edition__c > eventName= [Select Id,Name from Event_Edition__c where id =: eventEditionId];
        uAList=(List<String>) System.JSON.deserialize(uFAList, List<String>.class);
        system.debug(uAList);
        system.debug('amish');
        List<User_Form_Action__c> userAFList = [select id, Name,Is_Filled_Up__c,Form_Permission__r.Event_Edition_Form__r.Name,Form_Permission__r.Event_Edition_Form__r.Deadline__c, User_Form_Contact__c from User_Form_Action__c where Id IN: uAList];
        Set<Id> conId = new Set<Id>();
       // List<Id> conIdd = new List<Id>();
        for(User_Form_Action__c uAF: userAFList )
        {
            conId.add(uAF.User_Form_Contact__c );
            //conIdd.add(uAF.User_Form_Contact__c );
        }
        system.debug(conId);
        //List<User> usList = [select Email, id, Name,ContactId from User where ContactId=: conId]; 
        List<Contact> conList = [Select Email, id, Name, AccountId from Contact where id =: conId];    
        system.debug(conList );      
        List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c >();
        string tempContent = '';
        String tempSubject='';       
        if(string.isNotBlank(eventEditionId))
        {
            eeeTemplateList = [Select Id, Name, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c from Event_Edition_Email_Template__c where Event_Edition__c =:eventEditionId AND Email_Template_Code__c ='FOMSRM'];                 
        } 
        List<Messaging.SingleEmailMessage> massEmailLst= new List<Messaging.SingleEmailMessage>();       
        for (Contact con: conList) 
        { 
             List<String> tempFormList= new  List<String>();
             integer i = 0; 
             integer nonFill=0;
             integer assign=0;  
             integer fill;     
             for(User_Form_Action__c uAF: userAFList )
             {
                 
                 if (uAF.User_Form_Contact__c ==con.Id)
                 {
                     assign++; 
                     if (uAF.Is_Filled_Up__c!=true&&uAF.User_Form_Contact__c ==con.Id )                 
                     {
                         //System.Debug(uAF.Form_Permission__r.Event_Edition_Form__r.Name +'/' +uId);
                         i++;
                         nonFill++;
                         DateTime newDate = uAF.Form_Permission__r.Event_Edition_Form__r.Deadline__c;
                         if(newDate != null){
                             String deadline= newDate.format('MM-dd-yyyy');                        
                             tempFormList.add(i+'.'+uAF.Form_Permission__r.Event_Edition_Form__r.Name+'('+'Deadline: '+deadline+')');
                         }
                         else
                             //tempFormList.add(i+'.'+uAF.Form_Permission__r.Event_Edition_Form__r.Name+'('+'Deadline:'+')'); 
                             tempFormList.add(i+'.'+uAF.Form_Permission__r.Event_Edition_Form__r.Name);              
                     }
                 }
                 
             }
             fill = assign-nonFill;
             String filled= String.valueOf(fill);
             String assigned= String.valueOf(assign);
             system.debug(filled);
             system.debug(assigned);


             string forms='';
             for ( String tempFList: tempFormList)
             {
                 forms=forms+tempFList+'<br/>';               
             }    
            //system.debug('Email==='+uId.email);
            //system.debug('UName==='+uId.Name);
            // String userId= uId.id;
            // //system.debug(userId);
            if (tempFormList!=null && tempFormList.size()>0)
            {
                if(eeeTemplateList!=null && eeeTemplateList.size()>0 )
                {   
                    //tempContent = eeeTemplateList[0].Content__c.replaceAll('\\{User.Name\\}',uId.Name);
                    tempContent = eeeTemplateList[0].Content__c.replaceAll('\\{Event_Edition_Form__c.Name\\}',forms);
                    tempContent = tempContent.replaceAll('\\{Event_Edition_Form__c.Deadline__c\\}','');
                    //tempContent = tempContent.replaceAll('\\{Event_Edition_Form__c.Name\\}',forms);
                    tempContent = tempContent.replaceAll('\\{Number_of_Filled\\}',filled);
                    tempContent = tempContent.replaceAll('\\{Number_of_Assigned\\}',assigned);
                    tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c,con.Id);
                    tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c,con.AccountId);
                    //system.debug('tempContent==='+tempContent);                                      
                    tempSubject = eeeTemplateList[0].Subject__c.replaceAll('\\{Event_Edition__c.Name\\}',eventName[0].Name);
                    tempSubject = tempSubject.replaceAll('\\{Number_of_Filled\\}',filled);
                    tempSubject = tempSubject.replaceAll('\\{Number_of_Assigned\\}',assigned);
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


/*global class MassFormReminderEmail{
   webservice static boolean MassFormReminderEmail(String eventEditionId,String uFAList) 
    {   
        system.debug(eventEditionId);     
        List<String> uAList= new  List<String>();
        List<Event_Edition__c > eventName= [Select Id,Name from Event_Edition__c where id =: eventEditionId];
        uAList=(List<String>) System.JSON.deserialize(uFAList, List<String>.class);
        system.debug(uAList);
        system.debug('amish');
        List<User_Form_Action__c> userAFList = [select id, Name,Is_Filled_Up__c,Form_Permission__r.Event_Edition_Form__r.Name,Form_Permission__r.Event_Edition_Form__r.Deadline__c, User_Form_Contact__c from User_Form_Action__c where Id IN: uAList];
        Set<Id> conId = new Set<Id>();
       // List<Id> conIdd = new List<Id>();
        for(User_Form_Action__c uAF: userAFList )
        {
            conId.add(uAF.User_Form_Contact__c );
            //conIdd.add(uAF.User_Form_Contact__c );
        }
        system.debug(conId);
        List<User> usList = [select Email, id, Name,ContactId from User where ContactId=: conId];               
        system.debug(usList );      
        List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c >();
        string tempContent = '';
        String tempSubject='';       
        if(string.isNotBlank(eventEditionId))
        {
            eeeTemplateList = [Select Id, Name, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c from Event_Edition_Email_Template__c where Event_Edition__c =:eventEditionId AND Email_Template_Code__c ='FOMSRM'];                 
        } 
        List<Messaging.SingleEmailMessage> massEmailLst= new List<Messaging.SingleEmailMessage>();       
        for (User uId: usList) 
        { 
             List<String> tempFormList= new  List<String>();
             integer i = 0; 
             integer nonFill=0;
             integer assign=0;  
             integer fill;     
             for(User_Form_Action__c uAF: userAFList )
             {
                 
                 if (uAF.User_Form_Contact__c ==uId.ContactId)
                 {
                     assign++; 
                     if (uAF.Is_Filled_Up__c!=true&&uAF.User_Form_Contact__c ==uId.ContactId )                 
                     {
                         //System.Debug(uAF.Form_Permission__r.Event_Edition_Form__r.Name +'/' +uId);
                         i++;
                         nonFill++;
                         DateTime newDate = uAF.Form_Permission__r.Event_Edition_Form__r.Deadline__c;
                         if(newDate != null){
                             String deadline= newDate.format('MM-dd-yyyy');                        
                             tempFormList.add(i+'.'+uAF.Form_Permission__r.Event_Edition_Form__r.Name+'('+'Deadline: '+deadline+')');
                         }
                         else
                             //tempFormList.add(i+'.'+uAF.Form_Permission__r.Event_Edition_Form__r.Name+'('+'Deadline:'+')'); 
                             tempFormList.add(i+'.'+uAF.Form_Permission__r.Event_Edition_Form__r.Name);              
                     }
                 }
                 
             }
             fill = assign-nonFill;
             String filled= String.valueOf(fill);
             String assigned= String.valueOf(assign);
             system.debug(filled);
             system.debug(assigned);


             string forms='';
             for ( String tempFList: tempFormList)
             {
                 forms=forms+tempFList+'<br/>';               
             }    
            //system.debug('Email==='+uId.email);
            //system.debug('UName==='+uId.Name);
            // String userId= uId.id;
            // //system.debug(userId);
            if (tempFormList!=null && tempFormList.size()>0)
            {
                if(eeeTemplateList!=null && eeeTemplateList.size()>0 )
                {   
                    //tempContent = eeeTemplateList[0].Content__c.replaceAll('\\{User.Name\\}',uId.Name);
                    tempContent = eeeTemplateList[0].Content__c.replaceAll('\\{Event_Edition_Form__c.Name\\}',forms);
                    //tempContent = tempContent.replaceAll('\\{Event_Edition_Form__c.Name\\}',forms);
                    tempContent = tempContent.replaceAll('\\{Number_of_Filled\\}',filled);
                    tempContent = tempContent.replaceAll('\\{Number_of_Assigned\\}',assigned);
                    //system.debug(tempContent );
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