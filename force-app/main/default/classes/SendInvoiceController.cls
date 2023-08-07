/**
* File:        SendInvoiceController.cls
* Project:     GAP
* Date:        27/9/2017 
* Created By:  Abdul Kadir 
* Modified By:  Yash Gupta [20/12/2018] 
* Test Class:  SendInvoiceController_Test
* ***************************************************************************
* Description: This class purpose to send object(Any SFDC Object) attachments as in email as well as provide custom email send functionality.
* ****************************************************************************
* History: As per ticket GGCW-2208, we need to give functionality for [From Address] [GGCW-2793] [GGCW-2737] Yash Gupta and Rajesh Kumar
* History : Modified By Rajesh Kumar on BK-10230 - Date - 02-11-2020
*/
public class SendInvoiceController {

    //Variables Declaration
    public String parentId {get;set;}
    public String accountId {get;set;}
    public string toAddressesE{get;set;}
    public string ccAddressesE{get;set;}
    public string subject{get;set;}
    public string emailBody{get;set;}
    //public list<Attachment> attachmentList{get;set;}
    public list<ContentDocumentLink> attachmentList{get;set;}
    public list<String> attachmentListName{get;set;}
    public list<String> attachmentListID{get;set;}
    public String  returl;
    public OrgWideEmailAddress owea;
    public string toId{get;set;}
    public String sDocId{set;get;}
    public String DocName{get;set;}
    public Document headerlogo{get;set;}
    public Document footerlogo{get;set;}
    public string baseUrl{get;set;}
    public String sOrgId{get;set;}
    public boolean showUploadbutton{get;set;}
    public String sendObcLink{get;set;}
    public String currentUser{get;set;}
    public boolean sIsBillingStatusPosted{get;set;}
    public string sIsSourceAcc {get;set;}
    public string sIsSourceSSC {get;set;}
    public string sIsSourceOpp {get;set;}
    public string sContactId {get;set;}
    public string quoteId {get;set;}
    public string conga {get;set;}
    public string selectedFromAddress {get;set;}
    Map<Id, OrgWideEmailAddress> mapOrgWideAddressObj;
    public transient String fileName {get; set;}
    public transient Blob fileBody {get; set;}
    public transient string fileContentType {get; set;}
    
    public EmailTemplate emailTemplate{get;set;}
    public EmailTemplate oEmailTemplateSendOBCLink{get;set;}
    public string domainUrl{get;set;}
    public string EventId{get;set;}
    public string sOBCSendLinkURL{get;set;}
    //Constructor
    Public SendInvoiceController(){
        sIsBillingStatusPosted = false;
        mapOrgWideAddressObj = new Map<Id, OrgWideEmailAddress>();
        getOrgWideAddress();
        accountId = ApexPages.currentPage().getParameters().get('accountId');
        parentId = ApexPages.currentPage().getParameters().get('id');
        returl = ApexPages.currentPage().getParameters().get('retUrl');
        sIsSourceAcc = ApexPages.currentPage().getParameters().get('IsAccount');
        sIsSourceSSC = ApexPages.currentPage().getParameters().get('IsSSC');
        sIsSourceOpp = ApexPages.currentPage().getParameters().get('IsOpportunity');
        sContactId = ApexPages.currentPage().getParameters().get('ContactId');
        quoteId = ApexPages.currentPage().getParameters().get('quoteId');
        conga = ApexPages.currentPage().getParameters().get('conga');
        sendObcLink = ApexPages.currentPage().getParameters().get('sendObcLink') !=null? ApexPages.currentPage().getParameters().get('sendObcLink'):'0' ;
        showUploadbutton=true;
        attachmentListName = new list<String> ();
        attachmentListID = new list<String> ();
        if(parentId != null && parentId.startswith('a3D')){ //'006' for Invoice, 'a1D' for status objects
            attachmentList=[Select Id,ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId =  : parentId ORDER BY ContentDocument.CreatedDate Desc LIMIT 1];
            if(attachmentList.size() > 0){
                attachmentListID.add(attachmentList.get(0).ContentDocumentId);     attachmentListName.add(attachmentList.get(0).ContentDocument.Title);
            }
        }
        else{
            attachmentList = new list<ContentDocumentLink>();
        }
        owea = [select Id,address from
                OrgWideEmailAddress 
                where Address = 'globalexhibitionssfdc@informa.com' 
                limit 1];
        
        currentUser=UserInfo.getUserId();
        if(ApexPages.currentPage().getParameters().get('quoteId')!=null){
            retUrl=ApexPages.currentPage().getParameters().get('quoteId');
            String oppId=[Select SBQQ__Opportunity2__c 
                          From SBQQ__Quote__c
                          Where id=:retUrl 
                          limit 1].SBQQ__Opportunity2__c;
            
            String contactId=[Select Opportunity_Contact__c 
                              from Opportunity 
                              where id=:OppId 
                              limit 1].Opportunity_Contact__c;
            
            string primaryContactEmail=[select email 
                                        from contact 
                                        where id=:contactId 
                                        limit 1].email;
            
            toAddressesE=primaryContactEmail;
        }else if(ApexPages.currentPage().getParameters().get('retUrl')!=null){
            retUrl=ApexPages.currentPage().getParameters().get('retUrl');
            String OppId='';
            if(retUrl.startswith('001')){                OppId=[SELECT Id, Name FROM Contact  WHERE Contact.AccountId=:retUrl limit 1].ID;            
            } else if(retUrl.startswith('003')){                OppId=[SELECT Id, Name FROM Contact WHERE Id=:retUrl limit 1].ID;                
            } else{
                OppId=[SELECT Id, Name, Opportunity_Contact__r.Name,Opportunity_Contact__c 
                       FROM Opportunity 
                       where Id=:retUrl 
                       limit 1].Opportunity_Contact__c;                
            }
            String primaryContactEmail=[select email from contact 
                                        where id=:OppId 
                                        limit 1].email;            
            toAddressesE=primaryContactEmail;
        }
        //Condition to check whether status is posted or not to render condition for sending email as per ticket no. GGCW-1817
        List<blng__Invoice__c> billingInvoice = [Select Id,blng__InvoiceStatus__c 
                                                 From blng__Invoice__c 
                                                 Where Id =:parentId 
                                                 and OpportunityId__c =:returl 
                                                 and blng__Account__c =:accountId 
                                                 limit 1];
        if(billingInvoice.size()>0){
            if(billingInvoice[0].blng__InvoiceStatus__c != 'Posted'){
                sIsBillingStatusPosted = true;
            }
            else{
                sIsBillingStatusPosted = false;
            }
        }
        //Below Block Of code for the Send OBC Link Button ON opportunitySkuidDetail Page
        oEmailTemplateSendOBCLink =[SELECT Id, Subject, HtmlValue, Body 
                                    FROM EmailTemplate 
                                    WHERE Name = 'Send OBC Link By Email'
                                    limit 1];
        if(sendObcLink =='1'){
            List<Opportunity> strExpocadCoad =[SELECT Id, Name, Owner.name, Event_Edition__c, EventEdition__r.Event_Code__c,EventEdition__r.Id, EventEdition__r.Name, EventEdition__r.Start_Date__c, EventEdition__r.End_Date__c, EventEdition__r.Venue__c, Account.Name,Opportunity_Contact__r.Email FROM Opportunity where Id=:retUrl limit 1];
            if(strExpocadCoad.size() > 0){   Network myNetwork = [SELECT Id FROM Network WHERE Name ='Exhibitor Portal'];
                domainUrl = Network.getLoginUrl(myNetwork.id);
                sOBCSendLinkURL = domainUrl+'?EventId='+strExpocadCoad[0].EventEdition__r.Event_Code__c;
                String getLabelName = System.Label.Send_OBC_Link_Email;        emailBody=strExpocadCoad[0].Owner.name +' '+ getLabelName+' '+strExpocadCoad[0].EventEdition__r.Name +'.<br/>'+'To begin the process of securing your booth, <a href='+domainUrl+'?EventId='+strExpocadCoad[0].EventEdition__r.Event_Code__c+'> Click here </a>';
            }
        }
        //end
        sDocId = ApexPages.currentPage().getParameters().get('DocId');
        DocName = ApexPages.currentPage().getParameters().get('DocName');
        footerlogo=[select id,name 
                    from document 
                    where name='EmailTemplateFooter_Logo' 
                    limit 1];
        
        headerlogo=[select id,name 
                    from document 
                    where name='EmailTemplateHeader_Logo' 
                    limit 1];
        
        baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        sOrgId=[SELECT Id 
                FROM Organization 
                limit 1].Id;
        
        emailTemplate = [SELECT Id, Subject, HtmlValue, Body 
                         FROM EmailTemplate 
                         WHERE Name = 'custom email template' 
                         limit 1];
        if(sDocId!=null){            showUploadbutton=false;
        }
    }

/**
* @description This method set the user inputs like(to,from,subject,body) and prepare email template with attachments.
* @param 
* @return pageReference
*/
    public Pagereference sendContractMethod(){
        String[] toAddresses=String.isNotBlank(toAddressesE) ? toAddressesE.split(','):null;
        String[] ccAddresses=String.isNotBlank(ccAddressesE) ? ccAddressesE.split(','):null;
        try {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if(toAddressesE!=null){ mail.setToAddresses(toAddresses);}
            if(ccAddressesE!=null){ mail.setCcAddresses(ccAddresses);}
            String [] temp=emailBody.split('\n');
            emailBody='';
            for(String str : temp){ emailBody+=str+'<br/>';}
            if(mapOrgWideAddressObj.containsKey(selectedFromAddress)){                mail.setOrgWideEmailAddressId(mapOrgWideAddressObj.get(selectedFromAddress).Id);
            }
            mail.setSubject(subject);
            mail.setUseSignature(true);
            mail.setPlainTextBody(emailBody);
            if(emailTemplate!=null){
                String htmlBody  = emailTemplate.HtmlValue;
                htmlBody = htmlBody.replace('{!emailBody}',emailBody);
                htmlBody = htmlBody.replace('{!footerlogo}',baseUrl+'/servlet/servlet.ImageServer?oid='+sOrgId+'&id='+footerlogo.Id);
                htmlBody = htmlBody.replace('{!headerlogo}',baseUrl+'/servlet/servlet.ImageServer?oid='+sOrgId+'&id='+headerlogo.Id);
                mail.setHtmlBody(htmlBody);
                mail.setEntityAttachments(new ID[]{sDocId});
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
            
        } catch(Exception ex) {
            Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'SendInvoiceController(@sendContractMethod)');
        }
        string  headerdata= ApexPages.currentPage().getHeaders().get('Host');
        string  url='https://' + headerdata+ '/';
        PageReference reference = new PageReference(url+quoteId);
        If(!test.isRunningTest()){            reference.setRedirect(true);        
        }
        return reference;
        
    }

/**
* @description This method set the user inputs like(to,from,subject,body) and prepare email template with attachments.
* @param 
* @return pageReference
*/
    Public Pagereference sendInvoiceMethod(){
        String[] toAddresses=String.isNotBlank(toAddressesE) ? toAddressesE.split(','):null;
        String[] ccAddresses=String.isNotBlank(ccAddressesE) ? ccAddressesE.split(','):null;
        try {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if(toAddressesE!=null){ mail.setToAddresses(toAddresses);}
            if(ccAddressesE!=null){mail.setCcAddresses(ccAddresses);}
            String [] temp=emailBody.split('\n');
            emailBody='';
            for(String str : temp){emailBody+=str+'<br/>';}
            mail.setReplyTo(UserInfo.getUserEmail());
            if(mapOrgWideAddressObj.containsKey(selectedFromAddress)){          mail.setOrgWideEmailAddressId(mapOrgWideAddressObj.get(selectedFromAddress).Id);            
            }
            mail.setSubject(subject);
            mail.setUseSignature(true);
            mail.setPlainTextBody(emailBody);
            mail.setSaveAsActivity(true);
            if(retUrl.startswith('003')){
                EmailMessage emailMessage = new EmailMessage();
                emailMessage.status = '3'; // email was sent
                emailMessage.fromAddress = UserInfo.getUserEmail();
                emailMessage.fromName = UserInfo.getName();                 emailMessage.subject = subject;
                emailMessage.htmlBody = emailBody;                          emailMessage.toAddress = toAddressesE;
                emailMessage.CcAddress= ccAddressesE;                       emailMessage.fromSendController__c=retUrl;
                if(attachmentListID.size() > 0){                            emailMessage.attachmentId__c = attachmentListID[0];
                }
                insert emailMessage;
                /*
                    Modified By: Yash Gupta [GGCW-2969]
                */
                Task tk = new Task();             tk.Subject = subject;
                tk.Description = emailBody;       tk.OwnerId = Userinfo.getUserId(); 
                tk.WhoId = retUrl;                tk.ActivityDate = Date.Today();
                tk.Priority = 'Normal';           tk.Status = 'Completed';
                insert tk;
            }else{
                    mail.setWhatId(returl);
            }
            if(emailTemplate!=null){
                String htmlBody  = emailTemplate.HtmlValue;
                htmlBody = htmlBody.replace('{!emailBody}',emailBody);
                htmlBody = htmlBody.replace('{!footerlogo}',baseUrl+'/servlet/servlet.ImageServer?oid='+sOrgId+'&id='+footerlogo.Id);
                htmlBody = htmlBody.replace('{!headerlogo}',baseUrl+'/servlet/servlet.ImageServer?oid='+sOrgId+'&id='+headerlogo.Id);
                mail.setHtmlBody(htmlBody);
            }
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            for (ContentVersion a : [SELECT Title , VersionData , ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN : attachmentListID]){
                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                efa.setFileName(a.Title);
                efa.setBody(a.VersionData);
                fileAttachments.add(efa);
            }
            
            mail.setFileAttachments(fileAttachments);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } catch(DMLException ex) {            Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'SendInvoiceController(@sendInvoiceMethod)');
        }
        string  headerdata= ApexPages.currentPage().getHeaders().get('Host');
        string  url='https://' + headerdata+ '/';
        PageReference reference;
        if(sIsSourceOpp == 'true'){            reference = new PageReference(url+returl);    
        }
        if(sIsSourceAcc == 'true'){            reference = new PageReference(url+accountId);
        } 
        if(sIsSourceSSC == 'true'){            reference = new pageReference('/lightning/n/SSC_Dashboard1');
        }
        If(String.IsNotBlank(sContactId)){            reference = new PageReference(url+sContactId);
        }
        If(!test.isRunningTest()){            reference.setRedirect(true);        
        }
        return reference;
    }

/**
* @description This method redirect the page to the current Quote.
* @param 
* @return pageReference
*/
    public pageReference cancel(){
        string headerdata=ApexPages.currentPage().getHeaders().get('Host');
        pageReference pg;
        If(sIsSourceOpp == 'true'){            pg = new pageReference('/'+returl);
        }
        If(sIsSourceAcc == 'true'){            pg = new PageReference('/'+accountId);
        }
        If(sIsSourceSSC == 'true'){            pg = new pageReference('/lightning/n/SSC_Dashboard1');
        }
        If(String.IsNotBlank(sContactId)){            pg = new PageReference('/'+sContactId);
        }
        return pg;
    } 

/**
* @description This method upload the file and attach to the parent object's Note & Attachment related list.
* @param 
* @return 
*/
    public void upload() {
        try {
            if(String.IsNotBlank(fileName)){
                ContentVersion cVersion = new ContentVersion();
                cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
                cVersion.PathOnClient = fileName;//File name with extention
                cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
                cVersion.OwnerId = Userinfo.getUserId();//Owner of the file
                cVersion.Title = fileName;//Name of the file
                cVersion.VersionData = fileBody;//File content
                insert cVersion;
                Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
                ContentDocumentLink cDocLink = new ContentDocumentLink();        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
                cDocLink.LinkedEntityId = parentId;  cDocLink.ShareType = 'V'; cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
                insert cDocLink;           attachmentListName.add(cVersion.Title);      attachmentListID.add(conDocument);
            } else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select a file....'));
            }
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
            Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'SendInvoiceController(@upload Method)');
        } finally {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
        }
    }
    
/**
* @description Method to redirect to SSC dashboard
* @param 
* @return Pagereference
*/
    public pagereference reDirectToSSC(){
        pageReference pg;
        if(sIsSourceAcc == 'true'){            pg = new pageReference('/'+accountId);
        } 
        if(sIsSourceOpp == 'true'){            pg = new pageReference('/'+returl);
        }
        if(sIsSourceSSC == 'true'){            pg = new pageReference('/lightning/n/SSC_Dashboard1');        
        }
        return pg;
    }

/**
* @description This method set the user inputs like(to,from,subject,body) and prepare email template for sending the Send OBC Link.
* @param 
* @return pageReference
*/ 
    public Pagereference sendOBCLinkMethod(){
        String[] toAddresses=String.isNotBlank(toAddressesE) ? toAddressesE.split(','):null;
        String[] ccAddresses=String.isNotBlank(ccAddressesE) ? ccAddressesE.split(','):null;
        List<Opportunity> strExpocadCoad =[SELECT Id, Name, Owner.name, Event_Edition__c, EventEdition__r.Event_Code__c,EventEdition__r.Id, EventEdition__r.Name, EventEdition__r.Start_Date__c, EventEdition__r.End_Date__c, EventEdition__r.Venue__c, Account.Name,Opportunity_Contact__r.Email
                                           FROM Opportunity 
                                           where Id=:retUrl 
                                           limit 1];
        if(strExpocadCoad.size() > 0){
            Network myNetwork = [SELECT Id 
                                 FROM Network 
                                 WHERE Name ='Exhibitor Portal'];
            
            domainUrl = Network.getLoginUrl(myNetwork.id);
            sOBCSendLinkURL = domainUrl+'?EventId='+strExpocadCoad[0].EventEdition__r.Event_Code__c;
         }
        try {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if(toAddressesE!=null){ mail.setToAddresses(toAddresses);}
            if(ccAddressesE!=null){ mail.setCcAddresses(ccAddresses);}
            if(mapOrgWideAddressObj.containsKey(selectedFromAddress)){                mail.setOrgWideEmailAddressId(mapOrgWideAddressObj.get(selectedFromAddress).Id);                
            }
            mail.setSubject(subject);
            mail.setUseSignature(true);
            mail.setPlainTextBody(emailBody);
            if(oEmailTemplateSendOBCLink!=null){
                String htmlBody  = oEmailTemplateSendOBCLink.HtmlValue;
                htmlBody = htmlBody.replace('{!emailBody}',emailBody);
                htmlBody = htmlBody.replace('{!footerlogo}',baseUrl+'/servlet/servlet.ImageServer?oid='+sOrgId+'&id='+footerlogo.Id);
                htmlBody = htmlBody.replace('{!headerlogo}',baseUrl+'/servlet/servlet.ImageServer?oid='+sOrgId+'&id='+headerlogo.Id);
                htmlBody = htmlBody.replace('{!EventEditionId}',strExpocadCoad[0].EventEdition__c);
                htmlBody = htmlBody.replace('{!OppAccountName}',strExpocadCoad[0].Account.Name);
                htmlBody = htmlBody.replace('{!EventEditionname}',strExpocadCoad[0].EventEdition__r.name);
                htmlBody = htmlBody.replace('{!EventEditionStartdate}',string.valueOf(strExpocadCoad[0].EventEdition__r.Start_Date__c));
                htmlBody = htmlBody.replace('{!EventEditionEnddate}',string.valueOf(strExpocadCoad[0].EventEdition__r.End_Date__c));
                htmlBody = htmlBody.replace('{!Venue}',strExpocadCoad[0].EventEdition__r.Venue__c);
                htmlBody = htmlBody.replace('{!OpportunityOwnername}',strExpocadCoad[0].Owner.name);
                htmlBody = htmlBody.replace('{!OBCSendLinkURL}',sOBCSendLinkURL);
                htmlBody = htmlBody.replace('{!OpportunityContactEmail}',strExpocadCoad[0].Opportunity_Contact__r.Email);
                
                mail.setHtmlBody(htmlBody);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
            
        } catch(Exception ex) {
            Utility.logError(ex.getMessage(), ex.getCause(), ex.getLineNumber(), ex.getStackTraceString(), 'SendInvoiceController(@sendContractMethod)');
        }
        
        string  headerdata= ApexPages.currentPage().getHeaders().get('Host');
        string  url='https://' + headerdata+ '/';
        PageReference reference;
        if(sIsSourceOpp == 'true'){            reference = new PageReference(url+returl);    
        }
        if(sIsSourceAcc == 'true'){            reference = new PageReference(url+accountId);
        } 
        if(sIsSourceSSC == 'true'){            reference = new PageReference('/lightning/n/SSC_Dashboard1');
        }
        If(String.IsNotBlank(sContactId)){            reference = new PageReference(url+sContactId);
        }
        If(!test.isRunningTest()){            reference.setRedirect(true);        
        }
        return reference;
    }
    
/**
* @description List type method that return all OrgWideEmailAddress list as per ticket GGCW-2208.
* @param 
* @return List[SelectOption]
*/ 
    public List<SelectOption> getOrgWideAddress(){
        List<SelectOption> options = new List<SelectOption>();
        String sOrgAddressQry = 'select Id,address,DisplayName from OrgWideEmailAddress';
        options.add(new SelectOption(Userinfo.getUserId(), UserInfo.getUserEmail()));  
        for(OrgWideEmailAddress O : database.query(sOrgAddressQry)){
            mapOrgWideAddressObj.put(O.Id,O);
            options.add(new SelectOption(O.Id,O.address));  
            selectedFromAddress = Userinfo.getUserId();
        }       
        return options;
    }
}