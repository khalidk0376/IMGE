/**
 * Created/Modified By: Girikon(Aishwarya)
 * Created On:          12/21/2017
 * Modified On:         16/07/2021[BK-14824]
 * Description/Purpose: This batch class is called through the class- SingleManualReminderEmail
 * Methods:             execute, finish
 * Test Class:          SingleManualReminderEmail_Test
**/

public class SingleManualReminderEmailBatch implements Database.Batchable<sObject>{
    public String eventEditionId { get; set; }
    public String accList  { get; set; } //conList 
    public String EventEditionManual { get; set; }
    
    public SingleManualReminderEmailBatch(String eventEditionId, String accList, String EventEditionManual){
        this.eventEditionId = eventEditionId;
        this.accList  = accList  ; //accList 
        this.EventEditionManual = EventEditionManual;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        List<String> aList= new  List<String>(); //aList
        aList=(List<String>) System.JSON.deserialize(accList , List<String>.class); //accList
        system.debug('#################'+aList);
        alist= (List<String>) System.JSON.deserialize(accList, List<String>.class);
        Set<String> conSetIds= new Set<String>();
        
        List<ContactEventEditionMapping__c> ccEList = new List<ContactEventEditionMapping__c>();
        If(Test.isRunningTest()){
             ccEList = [Select Id, SFContactID__c FROM ContactEventEditionMapping__c where SFContactID__r.AccountId IN:alist AND SFEventEditionID__c =: eventEditionId];
        }
        else
        {
            ccEList = [Select Id, SFContactID__c FROM ContactEventEditionMapping__c where SFContactID__r.AccountId IN:alist AND SFEventEditionID__c =: eventEditionId 
                                              AND SFContactID__r.Account.IsCustomerPortal = true];// AND User_Type__c != null];
        }
        
        system.debug('====================='+ccEList+'SIZE::'+ccEList.size());
        if(!ccEList.IsEmpty())
        {
            for(ContactEventEditionMapping__c ceem: ccEList){
                conSetIds.add(ceem.SFContactID__c);
            }
        }
        return Database.getQueryLocator('Select Email, Id, Name, AccountId from Contact where id IN:conSetIds'); 
    }
    public void execute(Database.BatchableContext bc, List<Contact> contactList){
        System.debug('#### SCOPE '+contactList+'SIZE::'+contactList.Size());
        //System.debug('#### accList  '+accList  );
        //System.debug('#### EventEditionManual'+EventEditionManual);
        //SingleManualReminderEmailHandler.SingleManualReminderEmail(eventEditionId, accList , EventEditionManual); //conList
        List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c >();
        string tempContent = '';
        String tempSubject='';
        system.debug(eventEditionId);
        if(string.isNotBlank(eventEditionId)){
            eeeTemplateList = [Select Id, Name, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c FROM Event_Edition_Email_Template__c where Event_Edition__c =:eventEditionId AND Email_Template_Code__c ='MASIRM'];                 
            system.debug(eeeTemplateList);
        } 
        system.debug(eeeTemplateList);
        List<Messaging.SingleEmailMessage> massEmailLst= new List<Messaging.SingleEmailMessage>();
                                   
        for(integer i=0;i<contactList.size();i++)
        {
            system.debug('Email==='+contactList[i].email);
            if(eeeTemplateList!=null && eeeTemplateList.size()>0)
            {   
                //tempContent = eeeTemplateList[0].Content__c.replaceAll('\\{User.Name\\}',contactList[i].Name);
                tempContent = eeeTemplateList[0].Content__c.replaceAll('\\{Number_of_agreed\\}','');
                tempContent = tempContent.replaceAll('\\{Number_of_Assigned\\}','');
                tempContent= ParsePlaceholders.renderTemplate(tempContent ,eeeTemplateList[0].Event_Edition__c,contactList[i].Id);
                tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, contactList[i].AccountId); 
                tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, EventEditionManual);
                //tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, '0010n000003gM5d');
                //tempSubject = ParsePlaceholders.renderTemplate(eeeTemplateList[0].Subject__c,eeeTemplateList[0].Event_Edition__c);                   
                tempSubject = ParsePlaceholders.renderTemplate(eeeTemplateList[0].Subject__c ,eeeTemplateList[0].Event_Edition__c,contactList[i].Id);
                tempSubject = ParsePlaceholders.renderTemplate(tempSubject ,eeeTemplateList[0].Event_Edition__c,contactList[i].AccountId);
                tempSubject = ParsePlaceholders.renderTemplate(tempSubject ,eeeTemplateList[0].Event_Edition__c,EventEditionManual);
                system.debug('tempContent==='+tempContent);
            }
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] {contactList[i].Email});           
            email.setSaveAsActivity(false);
            email.setTargetObjectId(contactList[i].Id); 
            email.setHtmlBody(tempContent);
            email.setSubject(tempSubject);       
            massEmailLst.Add(email);
        }       
        system.debug('massEmailLst==='+massEmailLst);
        Messaging.sendEmail(massEmailLst);
    }
    public void finish(Database.BatchableContext bc)
    {
     System.debug('Batch is Completed');        
    }

}