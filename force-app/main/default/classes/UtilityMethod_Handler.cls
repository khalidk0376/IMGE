public with sharing class UtilityMethod_Handler {
    public static void sendEmailToExistingUser(set<Id> sConEEMIds) // if parameter is ContactEventEditionMapping Id [CCEN-585]
    {
        string sEmailBodyOne;
        string sEmailBodyTwo;
        String firstName; 
        String companyName;
        String userName;
        string sConMappingId;
        string sHeaderImage;
        string eventName;
        Map<Id,User> mapConUser = new Map<Id,User>();
        set<Id> sConId = new set<Id>();
        set<Id> sEventId = new set<Id>();
        Map<String,String> mapAccountsBooths = New Map<String,String>(); //BK-2736
         
        List<ContactEventEditionMapping__c> lstContactMapping = new List<ContactEventEditionMapping__c>();
        if(Schema.sObjectType.ContactEventEditionMapping__c.isAccessible()){
            lstContactMapping = [SELECT Id,SFContactID__r.AccountId,SFContactID__c, SFEventEditionID__c, IsEmailSent__c, User_Type__c, User_Type__r.Name,Agent_Email_Body_Content_1__c, Agent_Email_Body_Content_2__c FROM ContactEventEditionMapping__c WHERE id in:sConEEMIds];
        }
        for(ContactEventEditionMapping__c conEEM:lstContactMapping)
        {
            sConId.add(conEEM.SFContactID__c);
            sEventId.add(conEEM.SFEventEditionID__c);
        }
        mapAccountsBooths   =  UtilityMethods.getOppExpoBoothDetailsMap(sConId,sEventId); //BK-2736

        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        //Get existing user of contact with community profile
        List<User> lstUsr=[Select Id,Email,username,firstname,Contact.Type__c,ContactId,Contact.Event_Edition__c,Contact.account.name,Contact.name,Contact.email,IsActive,IsPortalEnabled from User where ContactId IN : sConId and IsPortalEnabled=true And Profile.Name='Customer Community Login User Custom' AND IsActive=true];  
        if(lstUsr != null && !lstUsr.IsEmpty()){
            for(User oUser : lstUsr){
                mapConUser.put(oUser.ContactId,oUser);
            }
        }
        //Get Email Template Id For Existing User
        EmailTemplate templateId = new  EmailTemplate();
        if(Schema.sObjectType.EmailTemplate.isAccessible()){
            templateId = [Select id,HtmlValue,Subject from EmailTemplate where DeveloperName = 'Exhibitor_Welcome_Email_Existing_User'];  
        }
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'do_not_reply_gecc@informa.com' Limit 1];
        
        map<Id,Event_Settings__c> mapEventSettings = new map<Id,Event_Settings__c>();
        List<Event_Settings__c> lstEventSetting = [SELECT Id, Event_Edition__c,Event_Edition__r.Name,Event_Edition__r.Event_Code__c, Co_Exhibitor_Email_Content1__c, Co_Exhibitor_Email_Content2__c, Exhibitor_Email_Content1__c, Exhibitor_Email_Content2__c, Agent_Email_Content1__c, Agent_Email_Content2__c, Stand_Contractor_Content1__c, Stand_Contractor_Content2__c, Welcome_Email_Banner__c, Organization_Id_Ops_Admin__c, Send_Welcome_Email__c, Is_Event_Edition_Live__c FROM Event_Settings__c WHERE Event_Edition__c IN :sEventId AND Send_Welcome_Email__c=true AND Is_Event_Edition_Live__c=true];
        
        for(Event_Settings__c evntSetting : lstEventSetting)
        {
            mapEventSettings.put(evntSetting.Event_Edition__c,evntSetting); 
        }
        
        String commUrl  =   UtilityMethods.getCommunityURL(); // Get Login Url BK-2736
        if(lstContactMapping.size()>0)
        {
            for(ContactEventEditionMapping__c conEvntMap : lstContactMapping){
                companyName         =   mapConUser.get(conEvntMap.SFContactID__c).Contact.account.name;
                firstName           =   mapConUser.get(conEvntMap.SFContactID__c).firstname;
                userName            =   mapConUser.get(conEvntMap.SFContactID__c).userName;
                String key          =   String.valueOf(conEvntMap.SFContactID__r.AccountId)+'#'+String.valueOf(conEvntMap.SFEventEditionID__c);
                String boothDetails =   mapAccountsBooths.ContainsKey(key)?mapAccountsBooths.get(key):'';
                
                if(mapEventSettings != null && !mapEventSettings.isEmpty() && mapEventSettings.containsKey(conEvntMap.SFEventEditionID__c))
                {   
                    eventName = mapEventSettings.get(conEvntMap.SFEventEditionID__c).Event_Edition__r.name; //Added regarding CCEN-725
                    if(mapEventSettings.get(conEvntMap.SFEventEditionID__c).Is_Event_Edition_Live__c == true && mapEventSettings.get(conEvntMap.SFEventEditionID__c).Send_Welcome_Email__c == true)
                    {
                        //BK-8006 Start
                        String imageURL = '';
                        if(System.Label.RTE_Image_Url !=null){
                            imageURL=System.Label.RTE_Image_Url;
                        } 
                        if(conEvntMap.User_Type__r.Name =='Exhibitor')
                        {
                            sEmailBodyTwo = mapEventSettings.get(conEvntMap.SFEventEditionID__c).Exhibitor_Email_Content2__c;
                            if(sEmailBodyTwo != null && sEmailBodyTwo !=''){
                                sEmailBodyTwo = sEmailBodyTwo.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                            }
                            sEmailBodyOne = mapEventSettings.get(conEvntMap.SFEventEditionID__c).Exhibitor_Email_Content1__c;
                            if(sEmailBodyOne !=null && sEmailBodyOne != ''){
                                sEmailBodyOne = sEmailBodyOne.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                            }
                        }
                        else if(conEvntMap.User_Type__r.Name =='Stand Contractor')
                        {
                            sEmailBodyTwo = mapEventSettings.get(conEvntMap.SFEventEditionID__c).Stand_Contractor_Content2__c;
                            if(sEmailBodyTwo != null && sEmailBodyTwo !=''){
                                sEmailBodyTwo = sEmailBodyTwo.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                            }
                            sEmailBodyOne = mapEventSettings.get(conEvntMap.SFEventEditionID__c).Stand_Contractor_Content1__c;
                            if(sEmailBodyOne !=null && sEmailBodyOne != ''){
                                sEmailBodyOne = sEmailBodyOne.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                            }
                        }
                        else if(conEvntMap.User_Type__r.Name =='Co-Exhibitor'){
                            sEmailBodyTwo = mapEventSettings.get(conEvntMap.SFEventEditionID__c).Co_Exhibitor_Email_Content2__c;
                            if(sEmailBodyTwo != null && sEmailBodyTwo !=''){
                                sEmailBodyTwo = sEmailBodyTwo.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                            }
                            sEmailBodyOne = mapEventSettings.get(conEvntMap.SFEventEditionID__c).Co_Exhibitor_Email_Content1__c;
                            if(sEmailBodyOne !=null && sEmailBodyOne != ''){
                                sEmailBodyOne = sEmailBodyOne.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                            }
                        }
                        else if(conEvntMap.User_Type__r.Name =='Agent'){
                            sEmailBodyTwo = mapEventSettings.get(conEvntMap.SFEventEditionID__c).Agent_Email_Content2__c;
                            if(sEmailBodyTwo != null && sEmailBodyTwo !=''){
                                sEmailBodyTwo = sEmailBodyTwo.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                            }
                            sEmailBodyOne = mapEventSettings.get(conEvntMap.SFEventEditionID__c).Agent_Email_Content1__c;
                            if(sEmailBodyOne !=null && sEmailBodyOne != ''){
                                sEmailBodyOne = sEmailBodyOne.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                            }
                        }
                        if(mapEventSettings.get(conEvntMap.SFEventEditionID__c).Welcome_Email_Banner__c != null && mapEventSettings.get(conEvntMap.SFEventEditionID__c).Organization_Id_Ops_Admin__c != null){
                            sHeaderImage =System.URL.getSalesforceBaseUrl().toExternalForm()+'/servlet/servlet.ImageServer?id='+mapEventSettings.get(conEvntMap.SFEventEditionID__c).Welcome_Email_Banner__c+'&oid='+mapEventSettings.get(conEvntMap.SFEventEditionID__c).Organization_Id_Ops_Admin__c;
                        }                        
                        //Send Email with replace values
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        // String boothDetails = getOppExpoBoothDetails(conEvntMap.SFContactID__c,conEvntMap.SFEventEditionID__c);
                        // String commUrl=getCommunityURL();
                        String htmlValue=templateId.HtmlValue;
                        if(!String.isBlank(htmlValue)) {
                            If(htmlValue.Contains('#company_name#') ){
                                if(!String.isBlank(companyName)){
                                    htmlValue=htmlValue.replace('{#company_name#}',CompanyName);
                                }
                                else{
                                    htmlValue=htmlValue.replace('{#company_name#}','');
                                }
                            }
                            If(htmlValue.Contains('#booth_details#') ){
                                if(!String.isBlank(boothDetails)){
                                    htmlValue=htmlValue.replace('{#booth_details#}',boothDetails);
                                }
                                else{
                                    htmlValue=htmlValue.replace('{#booth_details#}','');
                                }
                            }
                            If(htmlValue.Contains('#user_name#') ){
                                if(!String.isBlank(userName)){
                                    htmlValue=htmlValue.replace('{#user_name#}',userName);
                                }
                                else{
                                    htmlValue=htmlValue.replace('{#user_name#}','');
                                }
                            }
                            If(htmlValue.Contains('#comm_url#') ){
                                if(!String.isBlank(commUrl)){
                                    htmlValue=htmlValue.replace('{#comm_url#}',commUrl+'?eventcode='+mapEventSettings.get(conEvntMap.SFEventEditionID__c).Event_Edition__r.Event_Code__c);
                                }
                                else{
                                    htmlValue=htmlValue.replace('{#comm_url#}','');
                                }
                            }
                            If(htmlValue.Contains('#Email_Body1#') ){
                                if(!String.isBlank(sEmailBodyOne)){
                                    htmlValue=htmlValue.replace('{#Email_Body1#}',sEmailBodyOne);
                                }
                                else{
                                    htmlValue=htmlValue.replace('{#Email_Body1#}','');
                                }
                            }
                            If(htmlValue.Contains('#Email_Body2#') ){
                                if(!String.isBlank(sEmailBodyTwo)){
                                    htmlValue=htmlValue.replace('{#Email_Body2#}',sEmailBodyTwo);
                                }
                                else{
                                    htmlValue=htmlValue.replace('{#Email_Body2#}','');
                                }
                            }
                            If(htmlValue.Contains('#header_image#') ){
                                if(!String.isBlank(sHeaderImage)){
                                    htmlValue=htmlValue.replace('{#header_image#}',sHeaderImage);
                                }
                                else{
                                    htmlValue=htmlValue.replace('{#header_image#}','');
                                }
                            }
                        }
                        if (owea!=null && !owea.IsEmpty()){
                            mail.setOrgWideEmailAddressId(owea.get(0).Id);
                        }
                        //BK-12701
                        String emailSubject ='';
                        if(System.Label.Welcome_Email_Subject != null){
                            emailSubject = System.Label.Welcome_Email_Subject;
                        } 
                        //templateId.Subject=companyName + ' - Welcome to Customer Center for ' +eventName;
                        templateId.Subject=companyName +' '+ emailSubject +' '+ eventName;
                        mail.setSubject(templateId.Subject);
                        mail.setHtmlBody(htmlValue);
                        mail.setSaveAsActivity(false);
                        mail.setTargetObjectId(mapConUser.get(conEvntMap.SFContactID__c).id);
                        mail.setTemplateId(templateId.id);
                        mails.add(mail);
                    }
                }
            }
        }
        Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
    }
}