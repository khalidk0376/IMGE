/*
Created By      : Girikon(Sunil[STL-53])
Created On      : August 14 2019
@description    : This class is used as controller for ops_welcomeEmail LWC at Customer Centre.
Test Class      : OPS_WelcomeEmailCtrl_Test(97%)
Modified By     : [Aishwarya 15 Sep 2020 BK-8006]
Modified By     : [Rajesh kumar yadav 29 12 2020 BK-10225]
*/
public class OPS_WelcomeEmailCtrl {
    /*
* @description [Fetch Event_Settings__c, Event_Edition__c, Attachment ]
* @param  sEventId [Event_Edition__c Id to fetch records]
* @return          [EventEditionSettingWrap]
*/
    @AuraEnabled
    Public Static EventEditionSettingWrap getEventEditionSetting(String sEventId){
        EventEditionSettingWrap edsw=new EventEditionSettingWrap();
        if(sEventId!=null){
            Event_Edition__c eventEdition = new Event_Edition__c();
            List<Event_Settings__c> listEventSettings = new List<Event_Settings__c>();
            String eventSettingId='';
            eventEdition=[Select Id, Name, One_banner_sponsorship_cost__c from Event_Edition__c where Id=:sEventId];
            listEventSettings=[Select Id, Event_Edition__c,Exhibitor_Email_Content1__c, Exhibitor_Email_Content2__c, Event_Edition__r.Name, Organization_Id_Ops_Admin__c, 
                               Stand_Contractor_Content2__c, Stand_Contractor_Content1__c,Agent_Email_Content1__c,Agent_Email_Content2__c,Co_Exhibitor_Email_Content2__c,
                               Co_Exhibitor_Email_Content1__c, Welcome_Email_Banner__c, Contractor_Email_Content2__c, Contractor_Email_Content1__c
                               from Event_Settings__c 
                               where Event_Edition__c=:sEventId];
            
            edsw.eventEdition=eventEdition;
            if(!listEventSettings.isEmpty()){
                edsw.eventSettings=listEventSettings[0];
                
            }
        }
        edsw.sUserEmail=UserInfo.getUserEmail();
        return edsw;
    }
    
    /*
* @description [Save the email message]
* @param  eventSettingJson [Json which contains the required fields to save]
* @return null
*/
    @AuraEnabled
    Public Static boolean saveEventSetting(String eventSettingJson){
        EventSettingWrap esWrap = new EventSettingWrap();
        esWrap = (EventSettingWrap)JSON.deserialize(eventSettingJson, EventSettingWrap.class);
        List<Event_Settings__c> listEventSetting = new List<Event_Settings__c>();
        Event_Settings__c eSettingCreateUpdate=new Event_Settings__c();
        listEventSetting = [Select Id, Event_Edition__c,Exhibitor_Email_Content1__c, Exhibitor_Email_Content2__c,Stand_Contractor_Content2__c, Stand_Contractor_Content1__c,Agent_Email_Content1__c,Agent_Email_Content2__c,Co_Exhibitor_Email_Content2__c,
                            Co_Exhibitor_Email_Content1__c, Contractor_Email_Content2__c, Contractor_Email_Content1__c
                            from Event_Settings__c 
                            where Event_Edition__c=:esWrap.EventId];
        //BK-8006 Start
        String imageURL = '';
        if(System.Label.RTE_Image_Url !=null){
            imageURL=System.Label.RTE_Image_Url;
        }
        if(!listEventSetting.isEmpty()){
            eSettingCreateUpdate=listEventSetting[0];
            if(esWrap.selectedTab=='Exhibitor'){
                eSettingCreateUpdate.Exhibitor_Email_Content1__c = esWrap.boxType1Value;
                eSettingCreateUpdate.Exhibitor_Email_Content1__c = eSettingCreateUpdate.Exhibitor_Email_Content1__c.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                eSettingCreateUpdate.Exhibitor_Email_Content2__c = esWrap.boxType2Value;
                eSettingCreateUpdate.Exhibitor_Email_Content2__c = eSettingCreateUpdate.Exhibitor_Email_Content2__c.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
            }
            else if(esWrap.selectedTab=='Stand Contractor'){
                eSettingCreateUpdate.Stand_Contractor_Content1__c = esWrap.boxType1Value;
                eSettingCreateUpdate.Stand_Contractor_Content1__c = eSettingCreateUpdate.Stand_Contractor_Content1__c.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                eSettingCreateUpdate.Stand_Contractor_Content2__c = esWrap.boxType2Value;
                eSettingCreateUpdate.Stand_Contractor_Content2__c = eSettingCreateUpdate.Stand_Contractor_Content2__c.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
            }
            else if(esWrap.selectedTab=='Agent'){
                eSettingCreateUpdate.Agent_Email_Content1__c = esWrap.boxType1Value;
                eSettingCreateUpdate.Agent_Email_Content1__c = eSettingCreateUpdate.Agent_Email_Content1__c.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                eSettingCreateUpdate.Agent_Email_Content2__c = esWrap.boxType2Value;
                eSettingCreateUpdate.Agent_Email_Content2__c = eSettingCreateUpdate.Agent_Email_Content2__c.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
            }
            else if(esWrap.selectedTab=='Co-Exhibitor'){
                eSettingCreateUpdate.Co_Exhibitor_Email_Content1__c = esWrap.boxType1Value;
                eSettingCreateUpdate.Co_Exhibitor_Email_Content1__c = eSettingCreateUpdate.Co_Exhibitor_Email_Content1__c.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                eSettingCreateUpdate.Co_Exhibitor_Email_Content2__c = esWrap.boxType2Value;
                eSettingCreateUpdate.Co_Exhibitor_Email_Content2__c = eSettingCreateUpdate.Co_Exhibitor_Email_Content2__c.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
            }
            else if(esWrap.selectedTab=='Contractor'){
                eSettingCreateUpdate.Contractor_Email_Content1__c = esWrap.boxType1Value;
                eSettingCreateUpdate.Contractor_Email_Content1__c = eSettingCreateUpdate.Contractor_Email_Content1__c.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                eSettingCreateUpdate.Contractor_Email_Content2__c = esWrap.boxType2Value;
                eSettingCreateUpdate.Contractor_Email_Content2__c = eSettingCreateUpdate.Contractor_Email_Content2__c.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
            }
            //BK-8006 End
            upsert eSettingCreateUpdate;
            return true;
        }
        else{
            return false;
        }
    }
    
    /*
* @description [Sends welcome email to current user]
* @param  UserType [Type of user for eg. Exhibitor, Stand Contractor,Co-Exhibitor, Agent, Contractor]
* @param  sEventId [Event_Edition__c id to get the email message]
* @return [boolean]
*/
    @AuraEnabled
    public static boolean sendWelcomeEmailPreview(string UserType, string sEventId) { 
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
        Event_Settings__c oEventSetting = [SELECT Id, Co_Exhibitor_Email_Content1__c, Co_Exhibitor_Email_Content2__c, Exhibitor_Email_Content1__c, Exhibitor_Email_Content2__c, Agent_Email_Content1__c, Agent_Email_Content2__c, Stand_Contractor_Content1__c, Stand_Contractor_Content2__c,Contractor_Email_Content1__c,Contractor_Email_Content2__c, Welcome_Email_Banner__c, Organization_Id_Ops_Admin__c
                                           FROM Event_Settings__c
                                           WHERE Event_Edition__c = :sEventId][0];
        //BK-8006 Start
        String imageURL = '';
        if(System.Label.RTE_Image_Url !=null){
            imageURL=System.Label.RTE_Image_Url;
        }
        if(oEventSetting != null && (imageURL !='' || imageURL !=null)){
            if(UserType =='Exhibitor'){
                sEmailBodyTwo = oEventSetting.Exhibitor_Email_Content2__c;
                if(sEmailBodyTwo !=null && sEmailBodyTwo !=''){
                    sEmailBodyTwo = sEmailBodyTwo.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                }
                sEmailBodyOne = oEventSetting.Exhibitor_Email_Content1__c;
                if(sEmailBodyOne !=null && sEmailBodyOne !=''){
                    sEmailBodyOne = sEmailBodyOne.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                }
            }
            else if(UserType =='StandContractor'){
                sEmailBodyTwo = oEventSetting.Stand_Contractor_Content2__c;
                if(sEmailBodyTwo !=null && sEmailBodyTwo !=''){
                    sEmailBodyTwo = sEmailBodyTwo.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                }
                sEmailBodyOne = oEventSetting.Stand_Contractor_Content1__c;
                if(sEmailBodyOne !=null && sEmailBodyOne !=''){
                    sEmailBodyOne = sEmailBodyOne.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                }
            }
            else if(UserType =='Co-Exhibitor' || UserType =='Co_Exhibitor'){
                sEmailBodyTwo = oEventSetting.Co_Exhibitor_Email_Content2__c;
                if(sEmailBodyTwo !=null && sEmailBodyTwo !=''){
                    sEmailBodyTwo = sEmailBodyTwo.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                }
                sEmailBodyOne = oEventSetting.Co_Exhibitor_Email_Content1__c;
                if(sEmailBodyOne !=null && sEmailBodyOne !=''){
                    sEmailBodyOne = sEmailBodyOne.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                }
            }   
            else if(UserType =='Agent'){
                sEmailBodyTwo = oEventSetting.Agent_Email_Content2__c;
                if(sEmailBodyTwo !=null && sEmailBodyTwo !=''){
                    sEmailBodyTwo = sEmailBodyTwo.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                }
                sEmailBodyOne = oEventSetting.Agent_Email_Content1__c;
                if(sEmailBodyOne !=null && sEmailBodyOne !=''){
                    sEmailBodyOne = sEmailBodyOne.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                }
            }
            else if(UserType =='Contractor'){
                sEmailBodyTwo = oEventSetting.Contractor_Email_Content2__c;
                if(sEmailBodyTwo !=null && sEmailBodyTwo !=''){
                    sEmailBodyTwo = sEmailBodyTwo.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                }
                sEmailBodyOne = oEventSetting.Contractor_Email_Content1__c;
                if(sEmailBodyOne !=null && sEmailBodyOne !=''){
                    sEmailBodyOne = sEmailBodyOne.replaceall(imageURL,LtngUtilityCtrl.getCommunityURL().replace('/UserLogin', ''));
                }
            }
            //BK-8006 End
            if(oEventSetting.Welcome_Email_Banner__c != null && oEventSetting.Organization_Id_Ops_Admin__c != null){
                sHeaderImage =System.URL.getSalesforceBaseUrl().toExternalForm()+'/servlet/servlet.ImageServer?id='+oEventSetting.Welcome_Email_Banner__c+'&oid='+oEventSetting.Organization_Id_Ops_Admin__c;
            }
        }
        EmailTemplate templateId = [Select id, HtmlValue, Subject
                                    FROM EmailTemplate 
                                    where Name = 'Exhibitor Welcome Email Preview'
                                    LIMIT 1];
        
        OrgWideEmailAddress[] owea = [select Id 
                                      from OrgWideEmailAddress 
                                      where Address = 'do_not_reply.geinforma@informa.com' 
                                      LIMIT 1];
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
    /*
* @description [Saves image to attachment of Event_Settings__c]
* @param  idParent [Event_Settings__c id to attach file]
* @param  strFileName [Name of the file]
* @param  base64Data [File content]
* @return [string]
*/
    @AuraEnabled
    public static string saveFile(Id idParent, String strFileName, String base64Data, string eventId) {
        /*if(idParent!=null){
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            Attachment oAttachment = new Attachment();
            oAttachment.parentId = idParent;
            oAttachment.Body = EncodingUtil.base64Decode(base64Data);
            oAttachment.Name = strFileName;
            insert oAttachment;
            
            return oAttachment.Id; 
        }*/
        if(idParent!=null){
            ContentVersion cVersion = new ContentVersion();
            cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
            cVersion.PathOnClient = strFileName;//File name with extention
            cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
            cVersion.OwnerId = Userinfo.getUserId();//Owner of the file
            cVersion.Title = strFileName;//Name of the file
			base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            cVersion.VersionData =  EncodingUtil.base64Decode(base64Data);//File content
            insert cVersion;
            
            Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
            cDocLink.LinkedEntityId = idParent;//Add attachment parentId
            cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
            insert cDocLink;

            return cDocLink.ContentDocumentId;
        }
        return '';
    }
    
    /*
* @description [Save attachment to document and deletes attachment]
* @param  AttachmentId [Attachment id of the Event_Settings__c ]
* @param  sEventSettingId [Event_Settings__c Id]
* @return [boolean]
* AttachmentId is equal to ContentDocumentId
*/
    @AuraEnabled
    public static boolean attachDocument(String AttachmentId, String sEventSettingId){

        List<Document> listDocumentToInsert = new List<Document>();
        Map<Id,Event_Settings__c> mapEventSetting;
        Map<Id, ContentDocumentLink> mapAttachments;
        String sFolderid ='';
        Folder imageFolder = [Select Id, DeveloperName, Name,Type 
                              from Folder 
                              where DeveloperName='Images'][0];
        sFolderid=imageFolder.Id;
        mapAttachments = new Map<Id, ContentDocumentLink>([SELECT LinkedEntityId,ContentDocumentId 
                                                  FROM ContentDocumentLink 
                                                  WHERE LinkedEntityId =:sEventSettingId]);
        if(mapAttachments.size() > 0){
            ContentVersion contVers = [SELECT Id, ContentDocumentId,VersionData FROM ContentVersion where ContentDocumentId =: AttachmentId];
            Document oDocument = new Document();
            oDocument.Body = ContVers.VersionData;
            oDocument.Name = 'CustomerCenterEmailImage';
            oDocument.ContentType = 'image/png';
            oDocument.FolderId = sFolderid;
            oDocument.IsPublic  = true;
            listDocumentToInsert.add(oDocument);
        }
        if(listDocumentToInsert.size()>0)
            insert listDocumentToInsert;
        
        if(listDocumentToInsert.size()>0 && sEventSettingId !=''){
            mapEventSetting = new Map<Id,Event_Settings__c>([Select Id, Welcome_Email_Banner__c, Organization_Id_Ops_Admin__c
                                                             FROM Event_Settings__c
                                                             where Id =:sEventSettingId]);
            for(Event_Settings__c es : mapEventSetting.values()){
                es.Welcome_Email_Banner__c = listDocumentToInsert[0].Id;
                es.Organization_Id_Ops_Admin__c = UserInfo.getOrganizationId();
            }
            if(mapEventSetting.size()>0){
                update mapEventSetting.values();
            }
            if(mapAttachments.size()>0)
                delete mapAttachments.values();
        }
        return true;
    }
    
    /*
* @description [Sets Welcome_Email_Banner__c to null]
* @param  sEventSettingId [Event_Settings__c id to to update record]
* @return [boolean]
*/
    @AuraEnabled 
    public static boolean deleteImage(String sEventSettingId){
        Event_Settings__c eventSetting = new Event_Settings__c();
        if(sEventSettingId!=null){
            String nullBanner;
            eventSetting = [Select Id, Welcome_Email_Banner__c, Organization_Id_Ops_Admin__c
                            FROM Event_Settings__c 
                            where Id =:sEventSettingId];
            eventSetting.Welcome_Email_Banner__c=nullBanner;
            update eventSetting;
            return true;
        }
        else
            return false;
    }
    
    public class EventEditionSettingWrap{
        @AuraEnabled
        public Event_Edition__c eventEdition;
        @AuraEnabled
        public Event_Settings__c eventSettings;
        @AuraEnabled
        public String sUserEmail;
    }
    public class EventSettingWrap{
        @AuraEnabled
        public String EventId;
        @AuraEnabled
        public String boxType1Value;
        @AuraEnabled
        public String boxType2Value;
        @AuraEnabled
        public String selectedTab;
    }
}