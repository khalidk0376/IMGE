/**
 * Created : Girikon(Divaker)
 * Created On:          4 May 2018
 * Test Class:          SendWelcomeEmailPreview_Test(Code cover 94%)
**/

global class SendWelcomeEmailPreview{
    //This method used for perform send test welcome email from Ops Admin portal And will be called through skuid page :WelcomeEmailSetting
    webservice static boolean sendWelcomeEmail(string sendEmail, string UserType, string sEventId) { 
        string sEmailBodyOne='';
        string sEmailBodyTwo='';
        String FirstName;
        String CompanyName;
        String UserName;
        string sConMappingId;
        string sHeaderImage='';
        List<string> userEmail = new List<string>();
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        string currentUser = UserInfo.getUserId();
        Event_Settings__c oEventSetting = [SELECT Id, Co_Exhibitor_Email_Content1__c, Co_Exhibitor_Email_Content2__c, Exhibitor_Email_Content1__c, Exhibitor_Email_Content2__c, Agent_Email_Content1__c, Agent_Email_Content2__c, Stand_Contractor_Content1__c, Stand_Contractor_Content2__c,Contractor_Email_Content1__c,Contractor_Email_Content2__c, Welcome_Email_Banner__c, Organization_Id_Ops_Admin__c FROM Event_Settings__c WHERE Event_Edition__c = :sEventId];
        if(oEventSetting != null){
            if(UserType =='Exhibitor'){
                sEmailBodyTwo = oEventSetting.Exhibitor_Email_Content2__c;
                sEmailBodyOne = oEventSetting.Exhibitor_Email_Content1__c;
            }
            else if(UserType =='StandContractor'){
                sEmailBodyTwo = oEventSetting.Stand_Contractor_Content2__c;
                sEmailBodyOne = oEventSetting.Stand_Contractor_Content1__c;
            }
            else if(UserType =='Co-Exhibitor' || UserType =='Co_Exhibitor'){
                sEmailBodyTwo = oEventSetting.Co_Exhibitor_Email_Content2__c;
                sEmailBodyOne = oEventSetting.Co_Exhibitor_Email_Content1__c;
            }   
            else if(UserType =='Agent'){
                sEmailBodyTwo = oEventSetting.Agent_Email_Content2__c;
                sEmailBodyOne = oEventSetting.Agent_Email_Content1__c;
            }
            else if(UserType =='Contractor'){
                sEmailBodyOne = oEventSetting.Contractor_Email_Content1__c;
                sEmailBodyTwo = oEventSetting.Contractor_Email_Content2__c;
            }
            if(oEventSetting.Welcome_Email_Banner__c != null && oEventSetting.Organization_Id_Ops_Admin__c != null){
                sHeaderImage =System.URL.getSalesforceBaseUrl().toExternalForm()+'/servlet/servlet.ImageServer?id='+oEventSetting.Welcome_Email_Banner__c+'&oid='+oEventSetting.Organization_Id_Ops_Admin__c;
            }
        }
        EmailTemplate templateId = [Select id, HtmlValue, Subject FROM EmailTemplate where Name = 'Exhibitor Welcome Email Preview' LIMIT 1];
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'do_not_reply.geinforma@informa.com' LIMIT 1];
        if ( owea.size() > 0 ) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        String htmlValue=templateId.HtmlValue;
        if(!String.IsBlank(htmlValue))
        {
            if(!String.IsBlank(sEmailBodyOne))
            {
                htmlValue=htmlValue.replace('{#Email_Body1#}',sEmailBodyOne);
            }
            else {
                 htmlValue=htmlValue.replace('{#Email_Body1#}','');
            }
            if(!String.IsBlank(sEmailBodyTwo))
            {
                htmlValue=htmlValue.replace('{#Email_Body2#}',sEmailBodyTwo);
            }
            else {
               htmlValue=htmlValue.replace('{#Email_Body2#}','');
            }
            htmlValue=htmlValue.replace('{#header_image#}',sHeaderImage); 
        }
        mail.setSubject(templateId.Subject);
        mail.setHtmlBody(htmlValue); 
        mail.setSaveAsActivity(false);
        mail.setTargetObjectId(currentUser);
        mail.setTemplateId(templateId.id);
        mail.setBccAddresses(userEmail);
        mails.add(mail); 
        Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
        return true;
    }
}