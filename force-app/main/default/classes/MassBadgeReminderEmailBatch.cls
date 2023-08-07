/**
 * Created/Modified By: Girikon(Aishwarya) [CCEN-153]
 * Created On       : 09/25/2018
 * @description     : This batch class is called through the class: CustomerBadgesReportOpsCtrl
 * Methods          : execute, finish
 * Test Class       : CustomerBadgesReportOpsCtrl_Test(98%)
 *
 * Modification Log----- 
 * Modified by   :  Girikon(Ashish [CCEN-652 Feb 6 2019], Prashant [CCEN-737 May 3 2019] ,Girikon(Ashish [C2E-105 Sep 26 2019])
**/

public class MassBadgeReminderEmailBatch implements Database.Batchable<sObject>{
    public String eventEditionId { get; set; }
    public String accList { get; set; }
    
    public MassBadgeReminderEmailBatch(String eventEditionId, String accList)
    {
        this.eventEditionId = eventEditionId;
        this.accList= accList;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        List<String> accntList= new  List<String>();
        accntList =(List<String>) System.JSON.deserialize(accList, List<String>.class);  
        Set<Id> conIds = new Set<Id>();
        
        List<ContactEventEditionMapping__c>ccEList= [Select Id, SFContactID__c, SFContactID__r.AccountId FROM ContactEventEditionMapping__c  where SFContactID__r.AccountId IN: accntList AND SFEventEditionID__c =: eventEditionId  AND User_Type__c != null AND SFContactID__r.Email != null];//AND User_Type__r.Name ='Exhibitor'
        if(!ccEList.IsEmpty())
        {
            for (ContactEventEditionMapping__c ceem: ccEList)
            {
                if(string.isNotBlank(ceem.SFContactID__c)) 
                {
                    conIds.add(ceem.SFContactID__c);
                }
            }
        }        
        return Database.getQueryLocator('Select Email, id, Name, AccountId FROM Contact where Id IN:conIds');
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> conList){
        System.debug('#### ConList'+ConList.size());
        List<Event_Edition__c > eventName= [Select Id,Name from Event_Edition__c where id =: eventEditionId];
        List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c >();
        string tempContent = '';
        String tempSubject='';       
        if(string.isNotBlank(eventEditionId))
        {
            eeeTemplateList = [Select Id, Name, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c from Event_Edition_Email_Template__c where Event_Edition__c =:eventEditionId AND Email_Template_Code__c ='BADGEMRM'];                 
        }                                                                
        Organization orgName = [select id, Name from Organization Limit 1];                                                                            
        List<Messaging.SingleEmailMessage> massEmailLst= new List<Messaging.SingleEmailMessage>();       
        for(Contact con: conList) 
        { 
            List<String> tempFormList= new  List<String>();
            if(eeeTemplateList!=null && eeeTemplateList.size()>0 )
            {   
                tempContent = string.isNotBlank(eeeTemplateList[0].Content__c)? (eeeTemplateList[0].Content__c.replaceAll('\\{Contact.Name\\}',con.Name)):'';
                tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c,con.Id);
                tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c,con.AccountId);
                system.debug('tempContent==='+tempContent);                                      
                tempSubject = string.isNotBlank(eeeTemplateList[0].Subject__c)? (eeeTemplateList[0].Subject__c.replaceAll('\\{Event_Edition__c.Name\\}',eventName[0].Name)):'';
                tempSubject = eeeTemplateList[0].Subject__c.replaceAll('\\{Event_Edition__c.Name\\}',eventName[0].Name);
                tempSubject = ParsePlaceholders.renderTemplate(tempSubject ,eeeTemplateList[0].Event_Edition__c,con.Id);
                tempSubject = ParsePlaceholders.renderTemplate(tempSubject ,eeeTemplateList[0].Event_Edition__c,con.AccountId);                                 
            }
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] {con.email});
            email.setSaveAsActivity(false);
            //String[] ccAddresses = new String[] {''};
            //email.setccAddresses(ccAddresses);
            email.setTargetObjectId(con.Id); 
            email.setHtmlBody(tempContent);
            email.setSubject(tempSubject);     
            massEmailLst.Add(email);  
            system.debug('Email For '+con.email +' :::   '+email);
        }
        system.debug('Size : '+massEmailLst.size());
        try{
            if(massEmailLst!=null && massEmailLst.size()>0)
            {
                Messaging.sendEmail(massEmailLst,false); //Added False C2E - 105 
            }
        }
        catch(exception ex){ex.getMessage();}
    }
    public void finish(Database.BatchableContext bc)
    {
        System.debug('*****************************Reminder Email Sent Successfully******************************');
    }
}