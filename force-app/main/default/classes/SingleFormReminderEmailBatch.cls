/**
 * Created/Modified By: Girikon(Amish)
 * Created On:          12/21/2017
 * Modified On:         06/05/2018, 16/07/2021 [BK-14824]
 * Description/Purpose: This class is called through the class: SingleFormReminderEmail
 *                      This Class is for sending single email reminder bu calling the class SingleFormReminderEmailHandle
 * Methods:             execute, finish
 * Test Class:          SingleFormReminderEmail_Test
**/

public class SingleFormReminderEmailBatch implements Database.Batchable<sObject>{
    public String eventEditionId { get; set; }
    public String accList { get; set; }
    public String EventEditionForm { get; set; }
    
    public SingleFormReminderEmailBatch(String eventEditionId, String accList , String EventEditionForm){ //conList
        this.eventEditionId = eventEditionId;
        this.accList = accList ; 
        this.EventEditionForm = EventEditionForm;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        List<String> aList= new  List<String>();
        aList=(List<String>) System.JSON.deserialize(accList, List<String>.class);
        Set<String> conSetIds= new Set<String>();
        system.debug('########AccList'+aList);
        
        List<ContactEventEditionMapping__c>ccEList= [Select Id, SFContactID__c, SFContactID__r.AccountId from ContactEventEditionMapping__c where 
                                                            SFContactID__r.AccountId IN: alist AND SFEventEditionID__c =: eventEditionId]; //AND User_Type__c != null];
        if(!ccEList.IsEmpty()){
            for(ContactEventEditionMapping__c ceem: ccEList)
            {
                conSetIds.add(ceem.SFContactID__c);
            }
        }
        return Database.getQueryLocator('Select Id, Email, Name, AccountId FROM Contact where Id IN: conSetIds');
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> contactList){
        System.debug('#### eventEditionId'+eventEditionId);
        System.debug('########## contactList'+contactList+'SIZE::'+contactList.size());
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
        system.debug(accList);                           
        for(integer i=0;i<contactList.size();i++)
        {
            system.debug('Email==='+contactList[i].email);
            system.debug('id==='+contactList[i].id);
            if(eeeTemplateList!=null && eeeTemplateList.size()>0)
            {   
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
            email.setSubject(tempSubject);   
            massEmailLst.Add(email);
            email.setSubject(tempSubject);     
        }       
        system.debug('massEmailLst==='+massEmailLst);
        if(massEmailLst.size()>0)
            Messaging.sendEmail(massEmailLst);
    }
    
    public void finish(Database.BatchableContext bc)
    {
        System.debug('Batch is Completed');
    }

}