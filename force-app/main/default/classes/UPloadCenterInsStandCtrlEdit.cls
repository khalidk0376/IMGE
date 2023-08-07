/**
 * Created/Modified By: Girikon(Amish, Archit)
 * Created On:          10/31/2017
 * Description/Purpose: This class is the controller for "UPloadCenterInsStandEdit" VF pages
 *                      This class is used for editing and uploading new documents of type Insurance and Stand Approval for customer center
 * Methods:             saveDocument, checkFileFormat, sendEmailToCustomer
 * Test Class:          BadgesReminderEmail_Test
**/

public class UPloadCenterInsStandCtrlEdit
{
    public Upload_Center__c  oUploadCenterList{get;set;}
    public Attachment Att{get;set;}
    public String sMessage{get;set;}
    public String fileName{get;set;}
    public boolean check{get;set;}
    public String docuId{get;set;}
    public String Title{ get; set; }
    public String Notes{ get; set; }   
    public String Contact{ get; set; }
    //public String eventEdition{ get; set; }
    //public String ExpocadBooth{ get; set; }
    public String Account{ get; set; }
    public String existingDoc{ get; set; }
    public String existingDocId{ get; set; }
    public transient blob Photo{get;set;}
    public Boolean found {get;set;}
    public String errorMessage{get;set;}
    public Upload_Center__c upListing{ get; set; } 
    public string partOfSeries_FromURl;   
    public String ButtonBackgroundColor{get;set;}
    public String ButtonTextColor{get;set;}
    // Constructer that will grab the URL parameters       
    public UPloadCenterInsStandCtrlEdit()
    {
        oUploadCenterList = new Upload_Center__c();
        String docuId = ApexPages.currentPage().getParameters().get('docId').escapeHtml4();
        String scheck = ApexPages.currentPage().getParameters().get('check').escapeHtml4();
        partOfSeries_FromURl= ApexPages.currentPage().getParameters().get('posId').escapeHtml4();
        if(String.isNotBlank(scheck))
        {
            check=true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please Check for the correct file type Or you may have limit the max file size of 25MB')); 
        }             
        if(String.isNotBlank(docuId))
        {
               upListing= [select Id, Name, Notes__c, User__c, Contact__c, Event_Edition__c, Uploaded_Attachment_Id__c,Uploaded_Attachment_Name__c   from Upload_Center__c where id=:docuId limit 1];
               Title = upListing.Name ;
               Notes = upListing.Notes__c;             
               Contact= upListing.Contact__c;
               List <Attachment> Attach= [Select Id, name, parentId  from Attachment where parentId =: upListing.Id order by CreatedDate desc limit 1];
               if (Attach.size()!=null && Attach.size()>0)
               {
                   existingDoc=Attach[0].Name;   
                   existingDocId= Attach[0].Id; 
               }
                
                List<Event_Settings__c> eventSet = [Select Id, Name, Button_Text_Color__c,Button_colors__c, Branding_Color__c,Event_Edition__c, Event_Edition__r.Event_Code__c from Event_Settings__c where Event_Edition__c =: upListing.Event_Edition__c];
                if(!eventSet.IsEmpty())
                {
                    //BrandingColor = eventSet[0].Branding_Color__c;
                    //Added on enhancement project
                    ButtonBackgroundColor= eventSet[0].Button_colors__c;
                    ButtonTextColor = eventSet[0].Button_Text_Color__c;
                } 
            }                      
  
    }
    //function is used to update record and attach the new file to the records and send email notification to the contact and Ops admin
    public PageReference saveDocument()
    {
        try
        {
            String sEventId = ApexPages.currentPage().getParameters().get('eventId').escapeHtml4();
            String docuId = ApexPages.currentPage().getParameters().get('docId').escapeHtml4();
            
            Boolean flagCheck=true;
            Upload_Center__c upList = new Upload_Center__c();
            upList.ID = docuId;
            upList.Name = Title ;
            upList.Notes__c = Notes;
            upList.Event_Edition__c=upListing.Event_Edition__c;
            Attachment att = new Attachment();
            System.debug('fileName : '+fileName+'Photo '+Photo );
            if(String.isNotBlank(fileName) && Photo != null &&checkFileFormat(fileName))
            {
                //Attachment att = new Attachment();
                att.Name = fileName;
                att.Body = Photo;
                att.parentId = docuId ;//oUploadCenterList.id;
                if(att.body != null)
                { 
                    System.debug(Att.body.size()+'size of file');        
                    if(att.body.size()>25000000)
                    {
                        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'File is not Uploaded:Max.File Size is 25MB')); 
                        //check=true;
                        flagCheck=false;
                    }
                    else
                        flagCheck=true;
                }
                system.debug('====flagcheck= '+flagCheck);
                if(flagCheck)
                {                   
                    List<Attachment> attList = [Select Id from Attachment where parentId =:docuId ];
                    if(attList.size()>0)
                        delete attList;
                    insert att; 
                    upList.Uploaded_Attachment_Id__c = att.id;
                    upList.Uploaded_Attachment_Name__c = att.Name;
                    upList.Name=att.Name;
                    
                } 
                
            }
            if (String.isNotBlank(fileName) && Photo != null &&!checkFileFormat(fileName))
            {
                 //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please Check the file type')); 
                 //check=true;
                 flagCheck=false;
            }
           
            
            if(flagCheck)
            { system.debug('In Flag====');
                if(String.isNotBlank(fileName))
                {
                    update upList;
                    System.debug('upList:='+upList);
                    System.debug(partOfSeries_FromURl+','+upList.id+','+att.Id+','+att.Name+','+upList.Event_Edition__c);
                    //sending email to Ops Admin
                    sendEmailToOpsAdmin(partOfSeries_FromURl,upList.id,att.Id,att.Name,upList.Event_Edition__c);
                    // sending email to customer
                    sendEmailToCustomer(upList.id,att.Id,att.Name,upList.Event_Edition__c);
                    system.debug('In Flag====1');
                    PageReference redirectPage = Page.UPloadCenterInsStandEdit;
                    redirectPage.setRedirect(true);
                    redirectPage.getParameters().put('eventId',sEventId);
                    redirectPage.getParameters().put('docId',docuId);
                    return redirectPage; 
                }    
                else
                {
                    update upList;                    
                    system.debug('In Flag====2');
                    PageReference redirectPage = Page.UPloadCenterInsStandEdit;
                    redirectPage.setRedirect(true);
                    redirectPage.getParameters().put('eventId',sEventId);
                    redirectPage.getParameters().put('docId',docuId);
                    return redirectPage; 
                }
            }
            else
            {
                PageReference redirectPage = Page.UPloadCenterInsStandEdit;
                redirectPage.setRedirect(true);
                redirectPage.getParameters().put('eventId',sEventId);
                redirectPage.getParameters().put('docId',docuId);
                redirectPage.getParameters().put('posId',partOfSeries_FromURl);
                redirectPage.getParameters().put('check','true');
                return redirectPage;
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
        set<String> setExtAllowed = new set<String>(sFileTypes.split(',')); //Adding file format type.
        FileName= FileName.toLowerCase();
        List<String> parts = FileName.splitByCharacterType();
        if(!setExtAllowed.contains(parts[parts.size()-1])) // checking file format.
        {
            return false; //show error file format does not have pdf format. 
        }
        return true;        
    }
    // Method to send email to the Ops Admin
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
      
    // This function is used to send Email to user's contact
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
                email.setSubject(eeeTemplateList[0].Subject__c);     
                massEmailLst.Add(email);     
            }       
            system.debug('massEmailLst==='+massEmailLst);
            if(massEmailLst.size()>0) Messaging.sendEmail(massEmailLst);
         }
    }    
    
}