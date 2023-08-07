/**
* Project:         GAP
* Class Name :SendEmailCloseworkOrder_Trig 
* Test Class Name :RunDateCalculation_test   
* Code Coverage:   
* Created By:   Rajesh Kumar   
* *************************************************************************
* @Description:   This class use in workordertriggermerge
* *************************************************************************
* History:Ticket :GGCkB-76
* 
* */

public with sharing class SendEmailCloseworkOrder_Trig implements TriggerInterface_WorkOrder.Runnable{

    private set<string> woIds = new set<String>();
    private list<string> emailToAdd = new list<string>();
    private list<string> ownerIds = new list<string>();

    public void run(TriggerInterface_WorkOrder.Trig trig) {
        for(WorkOrder wo : trig.newList){
            if(wo.Status =='Closed'){
                woIds.add(wo.Id);
            }
        }
            
        list<WorkOrder> woStatus = [select id,WorkOrderNumber,Opportunity__r.OwnerId,Opportunity__r.Owner.FirstName,status, Opportunity__r.Owner.Email,Opportunity__r.Name,Opportunity__r.Account.Name,(select id, Team_Member__r.Email from WorkOrder_Teams__r) from WorkOrder where Id=:woIds];
        system.debug('woStatus :>>>'+woStatus );
        for(WorkOrder WoOrder: woStatus){
            for(WorkOrder_Team__c woteams : WoOrder.WorkOrder_Teams__r){
                emailToAdd.add(woteams.Team_Member__r.Email);
            }
        }
        
        string baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        system.debug('baseurl:>>>'+baseUrl);
        List<Messaging.SingleEmailMessage> lstSingleEmailMessage = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE Name = 'Informa Template2 For sendEmailCloseworkOrder'];

        for(WorkOrder wo : woStatus){
            Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
            List<String> toAddresses = new list<string>();
            toAddresses.add(wo.Opportunity__r.Owner.Email);
            for(String s : emailToAdd){
                toAddresses.add(s);
            }
            system.debug('toAddresses>>>'+toAddresses);
            String subject ='Work Order Status '+wo.Status;
            email.setSubject(subject);
            if(toAddresses!=null){
                email.setToAddresses( toAddresses );
            }
            
            String htmlBody = emailTemplate.HtmlValue;
            if(wo.Opportunity__r.Owner.FirstName !=null && wo.Opportunity__r.Owner.FirstName!=''){
                htmlBody = htmlBody.replace('{!oppOwner}', wo.Opportunity__r.Owner.FirstName);
            }
            htmlBody = htmlBody.replace('{!WorkOrder.WorkOrderNumber}', wo.WorkOrderNumber);
            htmlBody = htmlBody.replace('{!WorkOrder.Status}', wo.Status);
            if(wo.Opportunity__r.Account.Name !=null && wo.Opportunity__r.Account.Name!=''){
                htmlBody = htmlBody.replace('{!AccountName}', wo.Opportunity__r.Account.Name);
            }
            if(wo.Opportunity__r.Name !=null && wo.Opportunity__r.Name!=''){
                htmlBody = htmlBody.replace('{!oppName}', wo.Opportunity__r.Name);
            }
            htmlBody = htmlBody.replace('{!link}', +baseUrl+'/'+wo.Id);
            
            
            String plainBody = emailTemplate.Body;
            if(wo.Opportunity__r.Owner.FirstName !=null && wo.Opportunity__r.Owner.FirstName!=''){
                plainBody= plainBody.replace('{!oppOwner}', wo.Opportunity__r.Owner.FirstName);
            }
            plainBody = plainBody.replace('{!WorkOrder.WorkOrderNumber}', wo.WorkOrderNumber);
            plainBody= plainBody.replace('{!WorkOrder.Status}', wo.Status);
            if(wo.Opportunity__r.Account.Name !=null && wo.Opportunity__r.Account.Name!=''){
                plainBody= plainBody.replace('{!AccountName}', wo.Opportunity__r.Account.Name);
            }
            if(wo.Opportunity__r.Name !=null && wo.Opportunity__r.Name!=''){
                plainBody= plainBody.replace('{!oppName}', wo.Opportunity__r.Name);
            }
            plainBody= plainBody.replace('{!link}', +baseUrl+'/'+wo.Id);
            email.setHtmlBody(htmlBody);
            email.setSaveAsActivity(false);
            email.setPlainTextBody(plainBody);
            //email.setHtmlBody('<html><body><b>Hello '+wo.Opportunity__r.Owner.FirstName+'</b><br></br><br></br><b>'+wo.WorkOrderNumber+'</b> is '+wo.Status+'.<br></br><br></br><b>Opportunity Name: </b>'+wo.Opportunity__r.Name+'<br></br><br></br><b>Account Name: </b>'+wo.Opportunity__r.Account.Name+'<br></br><br></br><b>Work Order Link: </b><a href="'+baseUrl+'/'+wo.Id+'">'+baseUrl +'/'+wo.Id+'</a></body></html>');
            lstSingleEmailMessage.add(email);
            //Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
        }

        if(!test.isrunningtest()){
            Messaging.SendEmailResult[] r = Messaging.sendEmail(lstSingleEmailMessage);        
        }
    }
}