/**
 * Created/Modified By: Girikon(Aishwarya)
 * Created On:          06/07/2018, [Aishwarya BK-3759 27 Aug 2020]
 * Description/Purpose: This batch class is called through the class: FormAcceptEmail
 * Methods:             execute, finish
 * Test Class:          FormAcceptEmail_Test
**/

public class FormAcceptEmailBatch implements Database.Batchable<sObject>{
    public String eventEditionId   { get; set; }
    public String userActionId     { get; set; }
    public String EventEditionForm { get; set; }
    public String appprovalNote    { get; set; }
    
    public FormAcceptEmailBatch(String eventEditionId, String userActionId, String EventEditionForm, String appprovalNote){
        this.eventEditionId = eventEditionId;
        this.userActionId = userActionId;
        this.EventEditionForm = EventEditionForm;
        this.appprovalNote = appprovalNote;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        List<String> uAList = new  List<String>();
        Set<String> conSetIds = new Set<String>();
        List<User_Form_Action__c> uAFList = new List<User_Form_Action__c>([SELECT Id, Name, Form_Permission__r.Event_Edition_Form__r.Name, Account__c, User_Form_Contact__c, User_Type__c from User_Form_Action__c where Id=: userActionId LIMIT 1]); 
        System.debug('#####################uAFList'+uAFList);
        if(uAFList.size()>0)
        {
            if(uAFList[0].User_Form_Contact__c != null)
                conSetIds.add(uAFList[0].User_Form_Contact__c);
        }
        return Database.getQueryLocator('Select Id, Name, Email, AccountId FROM Contact where Id IN:conSetIds');
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> conList){
        system.debug('contact #'+conList.size());
        List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c >();
        string tempContent = '';
        String tempSubject='';    
        if(string.isNotBlank(eventEditionId)){                   
            eeeTemplateList = [Select Id, Name, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c 
                                      FROM Event_Edition_Email_Template__c where Event_Edition__c =:eventEditionId AND Email_Template_Code__c = 'FOAPPR'];                     
        } 
        List<Messaging.SingleEmailMessage> massEmailLst= new List<Messaging.SingleEmailMessage>();                       
        for(Contact c: conList)
        {
            system.debug('Email==='+c.email);
            system.debug('Email==='+c.Name);
            if(eeeTemplateList!=null && eeeTemplateList.size()>0)
            {   
                tempContent = eeeTemplateList[0].Content__c.replaceAll('\\{Number_of_Filled\\}','');
                tempContent = tempContent.replaceAll('\\{Number_of_Assigned\\}','');  
                tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, c.id);
                tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, userActionId);
                tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, EventEditionForm);
                tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, c.AccountId);
                tempSubject = ParsePlaceholders.renderTemplate(eeeTemplateList[0].Subject__c,eeeTemplateList[0].Event_Edition__c,c.Id);
                tempSubject = ParsePlaceholders.renderTemplate(tempSubject ,eeeTemplateList[0].Event_Edition__c,userActionId); 
                tempSubject = ParsePlaceholders.renderTemplate(tempSubject ,eeeTemplateList[0].Event_Edition__c,EventEditionForm);   
                tempSubject = ParsePlaceholders.renderTemplate(tempSubject ,eeeTemplateList[0].Event_Edition__c,c.AccountId);    
            }
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] {c.email});           
            email.setSaveAsActivity(false);
            email.setTargetObjectId(c.Id); 
            email.setHtmlBody(tempContent+'[Note: '+appprovalNote+ ' ]');
            email.setSubject(tempSubject);     
            massEmailLst.Add(email);    
        }      
        system.debug('massEmailLst==='+massEmailLst);
        if(massEmailLst.size()>0)
            Messaging.sendEmail(massEmailLst);
    }
    
    public void finish(Database.BatchableContext bc){
        // Added by Palla Kishore for the ticket Bk-19604
          system.debug('Batch job completed successfully');
    }
}

/*public class FormAcceptEmail{
    webservice static boolean FormAcceptEmail(String eventEditionId,String userActionId,String EventEditionForm, String appprovalNote) 
    { 
        List <User_Form_Action__c> uAF= [SELECT id,name,Form_Permission__r.Event_Edition_Form__r.Name,User_Form_Contact__c from User_Form_Action__c where ID =: userActionId limit 1]; 
        List<Contact> conList = [SELECT Id,Email,Name from Contact where id=:uAF[0].User_Form_Contact__c];
        //List<User> usList = [select Email, id, Name,ContactId from User where ContactId=: conList ];
        //system.debug(usList); 
        List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c >();
        string tempContent = '';
        String tempSubject='';    
        if(string.isNotBlank(eventEditionId))
        {                   
            eeeTemplateList = [Select Id, Name, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c 
                                        from Event_Edition_Email_Template__c where Event_Edition__c =:eventEditionId AND Email_Template_Code__c = 'FOAPPR'];                     
        } 
        List<Messaging.SingleEmailMessage> massEmailLst= new List<Messaging.SingleEmailMessage>();
        //system.debug( conList );                           
        for(Contact c: conList)
        {
            system.debug('Email==='+c.email);
            system.debug('Email==='+c.Name);
            if(eeeTemplateList!=null && eeeTemplateList.size()>0)
            {   
                //tempContent = eeeTemplateList[0].Content__c.replaceAll('\\{User.Name\\}',c.name);
                tempContent= ParsePlaceholders.renderTemplate(eeeTemplateList[0].Content__c,eeeTemplateList[0].Event_Edition__c, c.id);
                tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, userActionId);
                tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, EventEditionForm);
                tempSubject = ParsePlaceholders.renderTemplate(eeeTemplateList[0].Subject__c,eeeTemplateList[0].Event_Edition__c,EventEditionForm);
                system.debug('tempContent==='+tempContent);
            }
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] {c.email});           
            email.setSaveAsActivity(false);
            email.setTargetObjectId(c.Id); 
            email.setHtmlBody(tempContent+'[Note: '+appprovalNote+ ' ]');
            //email.setSubject(eeeTemplateList[0].Subject__c);
            email.setSubject(tempSubject);     
            massEmailLst.Add(email);    
        }      
        system.debug('massEmailLst==='+massEmailLst);
        Messaging.sendEmail(massEmailLst);
                
        return true;
    }
}*/