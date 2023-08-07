/**
 * Created/Modified By	: Girikon(Ashish)
 * Created On			: 20 Sep 2019 [C2E-105]
 * @description			: Send mass Emails For Agent Badges Status Change (Aproval/Rejection)
 * Test Class			: AgentBadgesReportOpsCtrl_Test
 * Code Coverage		: 95%
 * Last Modified By		: 
**/
public with sharing class BatchAgentBadgesStatusEmail implements Database.Batchable<sObject>
{
    String eventEditionId;
    set<String> agentBadgeIDs;
    String status;
    String note;

    public BatchAgentBadgesStatusEmail(set<String> badgeIDs,String status, String note)
    {
        this.agentBadgeIDs = new set<String>();
        this.agentBadgeIDs = badgeIDs;
        this.eventEditionId = ''; //eventEditionId;
        this.status = status;
        this.note = Note;
    }

     // Start Method
    public Database.QueryLocator start(Database.BatchableContext bthContext)
    {
       //return Database.getQueryLocator('Select Id,Event_Edition__c,Account__c,User_Name__c,User_Name__r.contactid,User_Name__r.contact.email,User_Name__r.contact.Name from Exhibitor_Badge__c where User_Name__r.contactid !=null And Account__c != null And User_Name__r.contact.Email != null And Id in :exhibitorBadgeIDs'); 
       return Database.getQueryLocator('Select Id,AgentEventEditionMapping__r.EventEdition__c,AgentEventEditionMapping__r.Account__c,CreatedById,CreatedBy.name,CreatedBy.ContactId,CreatedBy.Contact.Name,CreatedBy.Contact.email  from Agent_Badges__c where CreatedBy.ContactId != null And Id in :agentBadgeIDs AND AgentEventEditionMapping__r.Is_Active__c = true'); 
    }
    
    //Execute Logic
    public void execute(Database.BatchableContext bthContext, List<Agent_Badges__c> agentBadge) 
    {

        List<Messaging.SingleEmailMessage> massEmailLst  = new List<Messaging.SingleEmailMessage>();   
        if(agentBadge != null && !agentBadge.isEmpty())
        {
            eventEditionId = agentBadge[0].AgentEventEditionMapping__r.EventEdition__c;
            //System.debug('eventEditionId =============== '+eventEditionId);
            List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c >();
            string tempContent = '';
            String tempSubject=''; 
            if(string.isNotBlank(eventEditionId))
            {
                if (status=='Rejected')
                {
                    eeeTemplateList = [Select Id, Name, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c   from Event_Edition_Email_Template__c where Event_Edition__c =:eventEditionId AND Email_Template_Code__c = 'BDGREJ'];
                }
                if (status=='Approved')
                {
                    eeeTemplateList = [Select Id, Name, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c from Event_Edition_Email_Template__c where Event_Edition__c =:eventEditionId AND Email_Template_Code__c = 'BDGAPR'];
                }            
            }            
            Organization orgName = [select id, Name from Organization Limit 1];
            for (Agent_Badges__c ebadge : agentBadge)
            {
                if(eeeTemplateList!=null && eeeTemplateList.size()>0)
                {    
                    if(eeeTemplateList[0].Content__c != null && String.isNotBlank(eeeTemplateList[0].Content__c))
                    {
                        tempContent = eeeTemplateList[0].Content__c.replaceAll('Exhibitor_Badge__c','Agent_Badges__c');  // reuse the Old place holders
                    	tempContent = ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c,ebadge.CreatedBy.contactid);
                    	tempContent = ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c,ebadge.id);
                    	tempContent = ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c,ebadge.AgentEventEditionMapping__r.Account__c);                    
                    	tempContent = ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c,orgName.id); 
                    }                   
                    if(eeeTemplateList[0].Subject__c != null && string.isNotBlank(eeeTemplateList[0].Subject__c))
                    {
                        tempSubject = eeeTemplateList[0].Subject__c.replaceAll('Exhibitor_Badge__c','Agent_Badges__c');  // reuse the Old place holders
                    	tempSubject = ParsePlaceholders.renderTemplate(tempSubject,eeeTemplateList[0].Event_Edition__c,ebadge.CreatedBy.contactid);
                    	tempSubject = ParsePlaceholders.renderTemplate(tempSubject ,eeeTemplateList[0].Event_Edition__c,ebadge.id);             
                    	tempSubject = ParsePlaceholders.renderTemplate(tempSubject ,eeeTemplateList[0].Event_Edition__c,ebadge.AgentEventEditionMapping__r.Account__c);
                    	tempSubject= ParsePlaceholders.renderTemplate(tempSubject,eeeTemplateList[0].Event_Edition__c,orgName.id); 
                    }                    
                }
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] {ebadge.CreatedBy.contact.Email});                                  
                email.setSaveAsActivity(false);
                email.setTargetObjectId(ebadge.CreatedBy.contactId); 
                email.setHtmlBody(tempContent+'<br/>[<b>Note</b>: '+Note+ ' ]');                   
                email.setSubject(tempSubject );   
                massEmailLst.Add(email);
            }                
            system.debug('massEmailLst==='+massEmailLst);
        }
        Messaging.sendEmail(massEmailLst,false);
    }
    //  Logic to be Executed at finish   
    public void finish(Database.BatchableContext bthContext)
    {
        System.debug('*************************** Sending Email finished *******************************');
    }
}