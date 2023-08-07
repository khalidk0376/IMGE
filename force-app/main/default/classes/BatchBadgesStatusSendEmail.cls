/**
 * Created/Modified By  : Girikon(Ashish)
 * Created On           : 28 jan 2019 [CCEN-613]
 * @description         : Send mass Emails For Badges Status Change (Aproval/Rejection)
 * Test Class           : CustomerBadgesReportOpsCtrl_Test
 * Code Coverage        : 91%
 * Last Modified By     : 
**/
public with sharing class BatchBadgesStatusSendEmail implements Database.Batchable<sObject>,Database.Stateful
{
    String eventEditionId;
    set<String> exhibitorBadgeIDs;
    String status;
    String note;

    public BatchBadgesStatusSendEmail(set<String> badgeIDs,String status, String note)
    {
        this.exhibitorBadgeIDs = new set<String>();
        this.exhibitorBadgeIDs = badgeIDs;
        this.eventEditionId = ''; //eventEditionId;
        this.status = status;
        this.note = Note;       
    }

     // Start Method
    public Database.QueryLocator start(Database.BatchableContext bthContext)
    {
       return Database.getQueryLocator('Select Id,Event_Edition__c,Account__c,User_Name__c,User_Name__r.contactid,User_Name__r.contact.email,User_Name__r.contact.Name from Exhibitor_Badge__c where User_Name__r.contactid !=null And Account__c != null And User_Name__r.contact.Email != null And Id in :exhibitorBadgeIDs'); 
    }
    
    //Execute Logic
    public void execute(Database.BatchableContext bthContext, List<Exhibitor_Badge__c> exhibitorBadge) 
    {
        List<Messaging.SingleEmailMessage> massEmailLst  = new List<Messaging.SingleEmailMessage>();   
        if(exhibitorBadge != null && !exhibitorBadge.isEmpty())
        {
            eventEditionId = exhibitorBadge[0].Event_Edition__c;
            //System.debug('eventEditionId =============== '+eventEditionId);
            List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c >();
            string tempContent = '';
            String tempSubject=''; 
            if(string.isNotBlank(eventEditionId))
            {
                if (status=='Rejected')
                {
                    eeeTemplateList = [Select Id, Name, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c 
                                            from Event_Edition_Email_Template__c where Event_Edition__c =:eventEditionId AND Email_Template_Code__c = 'BDGREJ'];
                }
                if (status=='Approved')
                {
                    eeeTemplateList = [Select Id, Name, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c 
                                            from Event_Edition_Email_Template__c where Event_Edition__c =:eventEditionId AND Email_Template_Code__c = 'BDGAPR'];
                }            
            }
            for (Exhibitor_Badge__c ebadge : exhibitorBadge)
            {
                if(eeeTemplateList!=null && eeeTemplateList.size()>0)
                {               
                    tempContent= ParsePlaceholders.renderTemplate(eeeTemplateList[0].Content__c,eeeTemplateList[0].Event_Edition__c,ebadge.User_Name__r.contactid);
                    tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c,ebadge.id);
                    tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c,ebadge.Account__c);
                    
                    tempSubject = ParsePlaceholders.renderTemplate(eeeTemplateList[0].Subject__c,eeeTemplateList[0].Event_Edition__c,ebadge.User_Name__r.contactid);
                    tempSubject = ParsePlaceholders.renderTemplate(tempSubject ,eeeTemplateList[0].Event_Edition__c,ebadge.id);             
                    tempSubject = ParsePlaceholders.renderTemplate(tempSubject ,eeeTemplateList[0].Event_Edition__c,ebadge.Account__c); 
                }
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] {ebadge.User_Name__r.contact.Email});                                  
                email.setSaveAsActivity(false);
                email.setTargetObjectId(ebadge.User_Name__r.contactId); 
                email.setHtmlBody(tempContent+'[Note: '+Note+ ' ]');                   
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