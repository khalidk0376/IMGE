/**
 * Project:     GAP
 * Date:        04/12/2017
 * Created By:  Rajesh Kumar
 * Test Class:  cls_cancelOpportunity_Test [97%]
 * *************************************************************************
 * Description:   We have used this class in cancel opportunity and when updated resonse lost field than SSC_Email_Distribution get email with opportunity owner first name and Last name.
 * *************************************************************************
 * History:https://informa-ge-sfdc.atlassian.net/browse/BK-3006 
 * Rajesh Kumar Yadav Only SCA Work.
 **/

public class Cls_cancelOpportunity {

    public void redirectPopup(id oppId){
        EmailTemplate emailTemplObj = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE Name = 'Cancel Opportunity Email Template' LIMIT 1 ];     
        OrgWideEmailAddress[]  oWideEmailAdrs = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'GE Exhibitions' LIMIT 1];        
        for(Opportunity opp : [select id,accountId,Name,Account.Name,Owner.FirstName,Owner.LastName,Cancel_Reason__c,SSC_Email_Distribution_ID__c from Opportunity where Id =:oppId]){
            if(opp.Cancel_Reason__c !=null || opp.Cancel_Reason__c !='' ){
                List<Messaging.SingleEmailMessage> lstSingleEmailMessage = new List<Messaging.SingleEmailMessage>();               
                String htmlBody = emailTemplObj.HtmlValue;                
                Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
                List<String> toAddresses = new list<string>();

                if(opp.SSC_Email_Distribution_ID__c!=null){
                    toAddresses.add(opp.SSC_Email_Distribution_ID__c);
                } 

                if(!toAddresses.isEmpty()){
                    email.setToAddresses( toAddresses );
                                    
                    if(opp.Account.Name !=null && opp.Account.Name!=''){
                        htmlBody = htmlBody.replace('{!Opportunity.Account}', opp.Account.Name);
                    }
                    
                    if(opp.Name !=null && opp.Name!=''){
                        htmlBody = htmlBody.replace('{!Opportunity.Name}', opp.Name);
                    }
                                       
                    If(String.IsNotBlank(opp.Owner.FirstName)){
                        htmlBody = htmlBody.replace('{!Opportunity.OwnerFirstName}', opp.Owner.FirstName);
                    }  
                    htmlBody = htmlBody.replace('{!Opportunity.OwnerLastName}', opp.Owner.LastName);
                    if(opp.Cancel_Reason__c !=null && opp.Cancel_Reason__c!=''){
                        htmlBody = htmlBody.replace('{!Opportunity.Cancel_Reason__c}', opp.Cancel_Reason__c);
                    }
                    email.setSubject('Request to Cancel Opportunity');
                    email.setHtmlBody(htmlBody);
                    email.setSaveAsActivity(false);
                    email.setOrgWideEmailAddressId(oWideEmailAdrs[0].id);
                    lstSingleEmailMessage.add(email);
                }
                if(lstSingleEmailMessage!=null && lstSingleEmailMessage.size()>0){
                    Messaging.SendEmailResult[] r = Messaging.sendEmail(lstSingleEmailMessage);
                }
            }
        }
    }
}