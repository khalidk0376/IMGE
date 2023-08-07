/**
 * Created/Modified By: Girikon(Amish)
 * Created On:          10/27/2017
 * Description/Purpose: This class is the controller for "UploadCenterInsurance" VF pages
 *                      This class  is used for uploading new documents of type Insurance and Stand Approval for customer center
 * Methods:             saveDocument, checkFileFormat, sendEmailToCustomer
 * Test Class:          UploadCenterInsuranceCtrl_Test
**/

public class UploadCenterInsuranceCtrl
{
    public Upload_Center__c uploadCenter {get;set;}
    public Attachment Att{get;set;}
    public String sMessage{get;set;}
    public boolean check{get;set;}
    public boolean faultCheck{get;set;}
    public Transient Blob attBody{get;set;}
    public String attName{get;set;}
    public string eventCodeFromURl{get;set;}
   // public string uploadCenterId;
    //public string userActionForm_FromURl;
    public string partOfSeries_FromURl;
    public String contId;
    Public Contact contact;
    public String eventEditionId{get;set;}
    public boolean flagMessage{get;set;}
    public String ButtonBackgroundColor{get;set;}
    public String ButtonTextColor{get;set;}
    // Constructer that will grab the URL parameters
    public UploadCenterInsuranceCtrl()
    {
        uploadCenter  = new Upload_Center__c(); 
        contId=ApexPages.currentPage().getParameters().get('ContactId').escapeHtml4();
        eventCodeFromURl = ApexPages.currentPage().getParameters().get('eventCode').escapeHtml4();
        eventEditionId = ApexPages.currentPage().getParameters().get('eventId').escapeHtml4();
        contact = [Select id, name, type__c,type__r.Name from Contact where id=:contId];
        partOfSeries_FromURl= ApexPages.currentPage().getParameters().get('posId').escapeHtml4(); 
        //String DocId= ApexPages.currentPage().getParameters().get('DocId').escapeHtml4();
        String checkRender= ApexPages.currentPage().getParameters().get('checkRender').escapeHtml4();
        //If condition to check the correct document type, if true execute 
         if(eventEditionId != null)
        {
            List<Event_Settings__c> eventSet = [Select Id, Name, Button_Text_Color__c,Button_colors__c, Branding_Color__c,Event_Edition__c, Event_Edition__r.Event_Code__c from Event_Settings__c where Event_Edition__c =: eventEditionId ];
            if(!eventSet.IsEmpty())
            {
                //BrandingColor = eventSet[0].Branding_Color__c;
                //Added on enhancement project
                ButtonBackgroundColor= eventSet[0].Button_colors__c;
                ButtonTextColor = eventSet[0].Button_Text_Color__c;
            }
        }      
        if(String.isNotBlank(checkRender)&&checkRender=='true')
        {
                check=true;
                flagMessage=true;    
                //faultCheck= true;
                ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.Info,'Document has been added. Please close this window');
                ApexPages.addMessage(myMsg1);
        }
        //If condition to check the correct document type, if false execute     
        if (String.isNotBlank(checkRender)&&checkRender=='false')
        {
            //check=true;
            check=false;
            flagMessage=false;
           // faultCheck= false;
            ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.WARNING,'ERROR !!!!   Please check the document type');
            ApexPages.addMessage(myMsg1);
        }
         
    }
    //function is used to create new record and attach the file to the records and send email notification to the contact and Ops admin
    public PageReference saveDocument()
    {
        try
        {
            string eventCodeFromURl= ApexPages.currentPage().getParameters().get('eventCode').escapeHtml4();
            String eventEID  = ApexPages.currentPage().getParameters().get('eventId').escapeHtml4();
            String docType= ApexPages.currentPage().getParameters().get('docType').escapeHtml4();
            //String expoId = ApexPages.currentPage().getParameters().get('expoId'); 
            String conId = ApexPages.currentPage().getParameters().get('ContactId').escapeHtml4();           
            String checkRender= ApexPages.currentPage().getParameters().get('checkRender');
            //String DocId= ApexPages.currentPage().getParameters().get('DocId').escapeHtml4();
            if(String.isNotBlank(eventEID  ) && String.isNotBlank(conId ))//&&String.isBlank(checkRender))
            {             
                    //System.debug('fileName : '+fileName+'Photo '+Photo );
                    system.debug ('amishranjit');
                    if((String.isNotBlank(attName) && checkFileFormat(attName)))
                    {
                        uploadCenter.Event_Edition__c  = eventEID  ;
                        uploadCenter.Status__c = 'Pending';
                        uploadCenter.Contact__c  = conId;  
                        // condition to check if the doc type is Insurance or Stand Approval
                        if (docType=='01')
                        {
                            uploadCenter.Document_Type__c  = 'Insurance';
                        }
                        if (docType=='02')
                        {
                            uploadCenter.Document_Type__c  = 'Stand Approval';
                        }                      
                        uploadCenter.User__c = UserInfo.getUserId();                       
                        insert uploadCenter ;
                        
                        system.debug ('amish uploadCenter ='+uploadCenter);
                        //Attachment  att = new Attachment(Name=attName, Body = attBody,OwnerId = UserInfo.getUserId(),ParentId = oExhibitorDocument.id); 
                        Attachment  att = new Attachment(Name=attName, Body = attBody,ParentId = uploadCenter .id);                 
                        insert att;
                        
                        uploadCenter.Uploaded_Attachment_Id__c= Att.id;
                        uploadCenter.Uploaded_Attachment_Name__c = Att.Name;
                        uploadCenter.Name =  Att.Name;
                        update uploadCenter ; 
                        
                        //sending email to Ops Admin
                        sendEmailToOpsAdmin(partOfSeries_FromURl,uploadCenter.id,att.Id,att.Name,eventEditionId);
                        // sending email to customer
                        sendEmailToCustomer(uploadCenter.id,att.Id,att.Name,eventEditionId);
                         
                        PageReference redirectPage = Page.UploadCenterInsurance;
                        redirectPage.setRedirect(true);      redirectPage.getParameters().put('eventId',eventEID );
                        redirectPage.getParameters().put('ContactId',conId );      redirectPage.getParameters().put('checkRender','true');
                        //redirectPage.getParameters().put('DocId',oExhibitorDocument.id);
                        return redirectPage;   
                    }
                    else
                    {
                        PageReference redirectPage = Page.UploadCenterInsurance;
                        redirectPage.setRedirect(true);                        redirectPage.getParameters().put('eventId',eventEID  );
                        redirectPage.getParameters().put('ContactId',conId );                        redirectPage.getParameters().put('docType',docType);
                        redirectPage.getParameters().put('posId',partOfSeries_FromURl);                        redirectPage.getParameters().put('checkRender','false');
                        //redirectPage.getParameters().put('DocId',oExhibitorDocument.id);
                        return redirectPage; 
                    }
               //}
            }
        }
        catch(Exception e)
        {
           System.debug('Message:='+e.getMessage()+'**Line Number='+e.getLineNumber());
        }  
        return null;
    }
    // function is used to check the file format
    public Boolean checkFileFormat(String FileName)
    {
        String sFileTypes = (AllowedFileTypes__c.getValues('FileTypes') != null) ? AllowedFileTypes__c.getValues('FileTypes').Value__c : 'pdf'; //retrieve file type format name from custom setting.
        System.debug('sFileTypes;='+sFileTypes);
        set<String> setExtAllowed = new set<String>(sFileTypes.split(',')); //Adding file format type.
        FileName= FileName.toLowerCase();
        List<String> parts = FileName.splitByCharacterType();
        if(!setExtAllowed.contains(parts[parts.size()-1])) // checking file format.
        {
            return false; //show error file format does not have pdf format. 
        }
        return true;        
    }
    // This function is used to send Email to Operations Admin
    public void sendEmailToOpsAdmin(String posId,String ucId,String attId,String attName,String eventEditionId){
         List<Operations_Team_Member__c > otmList = new List<Operations_Team_Member__c >();
         List<Upload_Center__c > ucList = new List<Upload_Center__c >();
         List<ID> conIdList = new List<ID>();
         List<ID> userIdList = new List<ID>();
         List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c >();
         string tempContent = '';
         String tempSubject=''; 
         if(string.isNotBlank(UCId) && string.isNotBlank(AttId) && string.isNotBlank(AttName))
         { 
            ucList = [select id, Name, Contact__c, Uploaded_Attachment_Id__c, Uploaded_Attachment_Name__c from Upload_Center__c where id =:UCId];
         }
         system.debug('ucList ==='+ucList);
         if(ucList.size()>0){
            for (Upload_Center__c uc: ucList ){
                conIdList.add(uc.Contact__c);
            }
         }
         system.debug('conIdList ==='+conIdList );
         if(string.isNotBlank(posId))
         {
             otmList = [SELECT id,User_Name__c,Operations_Team__r.Event_Series__c FROM Operations_Team_Member__c WHERE Operations_Team__r.Event_Series__c =:posId];
         }
         system.debug('otmList ==='+otmList);
         if(otmList.size()>0){
            for (Operations_Team_Member__c otm: otmList){
                userIdList.add(otm.User_Name__c);
            }
         }
         system.debug('userIdList==='+userIdList);
         if(string.isNotBlank(eventEditionId))
         {
            eeeTemplateList = [Select Id, Name, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c 
                                    from Event_Edition_Email_Template__c where Event_Edition__c =:eventEditionId AND Email_Template_Code__c = 'DUNTOA'];
         }
         
         if(userIdList.size()>0){
            Contact con = [select Email, id, Name,AccountId, Type__c,FirstName from Contact where id in: conIdList limit 1];
            List<User> userList = [select Email, id, Name from User where id in: userIdList];
            //EmailTemplate et=[select id,Name from EmailTemplate where name = 'UploadCenterEmail_ForOpsAdmin' limit 1];
            List<Messaging.SingleEmailMessage> massEmailLst= new List<Messaging.SingleEmailMessage>();
            for (User u: userList)
            {
                system.debug('UserEmail==='+u.email);
                system.debug('UserName==='+u.name);
                if(eeeTemplateList!=null && eeeTemplateList.size()>0)
                {
                    tempContent = eeeTemplateList[0].Content__c.replaceAll('\\{Operation_Admin_Name\\}',u.name);
                    tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c,ucId);
                    tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, con.id); // added by amish
                    tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, con.AccountId);
                    //Subject
                    tempSubject = ParsePlaceholders.renderTemplate(eeeTemplateList[0].Subject__c,eeeTemplateList[0].Event_Edition__c,ucId);
                    tempSubject = ParsePlaceholders.renderTemplate(tempSubject ,eeeTemplateList[0].Event_Edition__c,con.id); 
                    tempSubject = ParsePlaceholders.renderTemplate(tempSubject ,eeeTemplateList[0].Event_Edition__c,con.AccountId);  
                    system.debug('tempContent==='+tempContent);
                }
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] {u.email});           
                email.setSaveAsActivity(false);
                email.setTargetObjectId(u.Id); 
                //email.setTemplateId(et.id);
                email.setHtmlBody(tempContent);
                email.setSubject(eeeTemplateList[0].Subject__c);     
                massEmailLst.Add(email);
                
            }       
            system.debug('massEmailLst==='+massEmailLst);
            if(massEmailLst.size()>0) Messaging.sendEmail(massEmailLst);
         }
    }
      
    // This function is used to send Email to contact
    public void sendEmailToCustomer(String UCId, String AttId, String AttName, String eventEditionId)     
    {   
        List<Upload_Center__c > ucList = new List<Upload_Center__c >();
        //List<Contact> conList= new List<Contact>();
        List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c >();
        string tempContent = '';
        String tempSubject='';  
        List<ID> IdList = new List<ID>();
        if(string.isNotBlank(UCId) && string.isNotBlank(AttId) && string.isNotBlank(AttName))
        { 
            ucList = [select id, Name, Contact__c,Contact__r.AccountID, Uploaded_Attachment_Id__c, Uploaded_Attachment_Name__c from Upload_Center__c where id =:UCId];            
        }        
        if(string.isNotBlank(eventEditionId))
        {
            eeeTemplateList = [Select Id, Name, Content__c,Email_Template_Code__c, Subject__c, Email_Template__c, Event_Edition__c 
                                    from Event_Edition_Email_Template__c where Event_Edition__c =:eventEditionId AND Email_Template_Code__c = 'DUNTC'];
            if(eeeTemplateList!=null && eeeTemplateList.size()>0)
            {
                tempContent= ParsePlaceholders.renderTemplate(eeeTemplateList[0].Content__c,eeeTemplateList[0].Event_Edition__c,ucList[0].id );// added by amish (ucLIst[0].id part only)
                tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, ucList[0].Contact__c); // added by amish
                tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, ucList[0].Contact__r.AccountID);
                //Subject
                tempSubject = ParsePlaceholders.renderTemplate(eeeTemplateList[0].Subject__c,eeeTemplateList[0].Event_Edition__c,ucList[0].id );
                tempSubject = ParsePlaceholders.renderTemplate(tempSubject ,eeeTemplateList[0].Event_Edition__c,ucList[0].Contact__c); 
                tempSubject = ParsePlaceholders.renderTemplate(tempSubject ,eeeTemplateList[0].Event_Edition__c,ucList[0].Contact__r.AccountID); 
                system.debug('tempContent==='+tempContent);
            }
        }
        system.debug('ucList ==='+ucList);
        if(ucList.size()>0){
            for (Upload_Center__c uc: ucList ){
                IdList.add(uc.Contact__c);
            }
        }
        system.debug('IdList==='+IdList);
        if(IdList.size()>0){
            List<Contact> conList = [select Email, id, Name from Contact where id in: IdList ];
            //EmailTemplate et=[select id,Name from EmailTemplate where name = 'UploadCenterEmail_ForCustomer' limit 1];
            List<Messaging.SingleEmailMessage> massEmailLst= new List<Messaging.SingleEmailMessage>();
            for (Contact con: conList )
            {
                system.debug(con.email);
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] {con.email});           
                email.setSaveAsActivity(false);
                email.setTargetObjectId(con.Id); 
                //email.setTemplateId(et.id);
                email.setHtmlBody(tempContent);
                email.setSubject(eeeTemplateList[0].Subject__c);                   massEmailLst.Add(email);     
            }       
            system.debug('massEmailLst==='+massEmailLst);
            if(massEmailLst.size()>0) Messaging.sendEmail(massEmailLst);
         }
    }    
}