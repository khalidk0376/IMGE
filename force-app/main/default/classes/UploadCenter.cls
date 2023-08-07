/**
 * Created/Modified By: Girikon(Archit)/Himanshu Jasuja[BK - 3748]
 * Created On:          6/22/2017 
 * Description/Purpose: This class is called through the VF page: UploadCenter for the Skuid page - CustomerUploadCenter.
 * Methods:             getItems, upload, sendEmailToOpsAdmin, sendEmailToCustomer, updateUserFormAction, updateAttOnUploadCenter, checkFileFormat
 * Test Class:          UploadCenter_Test
 * History: BK-3758 Modified By Rajesh Kumar - on 28-05-2020
**/

public class UploadCenter
{
    public string nameFile{get;set;}
    public Blob contentFile{get;set;}
    String[] filelines = new String[]{};
    List<Attachment> attachementList;
    public string eventCodeFromURl{get;set;}
    public string uploadCenterId;
    public string userActionForm_FromURl;
    public string partOfSeries_FromURl;
    public boolean check {get;set;}
    public Upload_Center__c uploadCenter{get;set;}
    public String eventEditionId{get;set;}
    public String ContactId;
    public Attachment attachment{get;set;}
    public Transient Blob attBody{get;set;}
    public String attName{get;set;}
    public Boolean isShowUserAction{get;set;}
    public User oUser ;
    public String sMessage{get;set;}
    public UploadCenter()
    {
         //Added escapeHtml4() - BK - 3748
        uploadCenter = new Upload_Center__c();
        ContactId =ApexPages.currentPage().getParameters().get('ContactId').escapeHtml4();
        eventCodeFromURl = ApexPages.currentPage().getParameters().get('eventCode').escapeHtml4();
        eventEditionId = ApexPages.currentPage().getParameters().get('eventId').escapeHtml4();
        oUser = [Select id,ContactId,Contact.type__r.Name from User where id=:UserInfo.getUserId()];
        userActionForm_FromURl = ApexPages.currentPage().getParameters().get('ufaID').escapeHtml4();
        partOfSeries_FromURl= ApexPages.currentPage().getParameters().get('posId').escapeHtml4();
        system.debug('eventCodeFromURl  === '+eventCodeFromURl );
        system.debug('userActionForm_FromURl  === '+userActionForm_FromURl);
        system.debug('uploadCenterId   === '+uploadCenterId );
        system.debug('partOfSeries_FromURl === '+partOfSeries_FromURl);
        check =false;
        sMessage ='';
        isShowUserAction =false;
    }
    
      public List<SelectOption> getItems() {
            List<SelectOption> options = new List<SelectOption>();
            List<String> lstName = new List<String>();
            lstName.add(oUser.Contact.type__r.Name);
            List<Event_Edition_Form__c> lstEvtEditionFrom = new List<Event_Edition_Form__c>();
            lstEvtEditionFrom =[select id, Name from Event_Edition_Form__c where Event_Edition__r.Event_Code__c = : eventCodeFromURl And User_Type__c =: oUser.Contact.type__r.Name and Form_Type__c='Downloadable PDF'];
            for(Event_Edition_Form__c oEvtEdForm :lstEvtEditionFrom){ options.add(new SelectOption(oEvtEdForm.id,oEvtEdForm.Name));
            }
            return options;
        }
     
     /*** Function that uplaods file for the Upload_Center__c custom object. ***/
      public PageReference upload() {
        Savepoint sp = Database.setSavepoint();
        try 
        {
            if((String.isNotBlank(attName) && checkFileFormat(attName)))
            {
                uploadCenter.Event_Edition__c  = eventEditionId ;
                uploadCenter.Status__c = 'Pending'; uploadCenter.Contact__c  = oUser.ContactId ;
                if(uploadCenter.Document_Type__c !=null && uploadCenter.Document_Type__c =='PDF Form'){
                    List<User_Form_Action__c> lstUForAction = new  List<User_Form_Action__c>([Select id,User__c,User_Form_Contact__c from User_Form_Action__c where Form_Permission__r.Event_Edition_Form__c =:uploadCenter.Event_Edition_Form__c and User_Form_Contact__c =:oUser.ContactId and Form_Permission__r.Active__c =true LIMIT 1]) ;
                    if(lstUForAction != null && lstUForAction.size()>0)
                    {
                        uploadCenter.User_Form_Action__c  = userActionForm_FromURl= lstUForAction[0].id;
                    }
                }
                else{
                     uploadCenter.Event_Edition_Form__c =null; uploadCenter.User_Form_Action__c =null;
                }
              uploadCenter.User__c = UserInfo.getUserId();
              insert uploadCenter; uploadCenterId = uploadCenter.id;
              partOfSeries_FromURl = [Select Part_of_Series__c from Event_Edition__c where Id=:eventEditionId].Part_of_Series__c;
              system.debug('partOfSeries_FromURl=== '+partOfSeries_FromURl);
              Attachment  att = new Attachment(Name=attName, Body = attBody,OwnerId = UserInfo.getUserId(),ParentId = uploadCenterId );
                   // the record the file is attached to
                  insert att;
              
              //attachementList = [Select Id, Name from Attachment where parentID =:uploadCenterId ORDER BY CreatedDate DESC Limit 1];
              updateAttOnUploadCenter(uploadCenterId,att.Id,att.Name);

              //Send mail Admin, User
              if(string.isNotBlank(userActionForm_FromURl)) updateUserFormAction(userActionForm_FromURl); sendEmailToCustomer(uploadCenterId,att.Id,att.Name,eventEditionId);sendEmailToOpsAdmin(partOfSeries_FromURl,uploadCenterId,att.Id,att.Name,eventEditionId);
            }
            else{
              sMessage='Please upload file pdf format.'; 
              return null;
            }
        } 
           //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error in uploading the attachment'+e.getLineNumber()+e.getMessage()));
      
        catch (DMLException e) { sMessage =e.getMessage(); Database.RollBack(sp); uploadCenter = new Upload_Center__c();return null;    } 
        finally {
          attachment = new Attachment(); 
        }
        sMessage ='Attachment uploaded successfully. Please close this window.'; ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully. Please close this window.'));check = true; return null;
      }           
    // This function is used to send Email to Operations Admin
    public void sendEmailToOpsAdmin(String posId,String ucId,String attId,String attName,String eventEditionId){
         List<Operations_Team_Member__c > otmList = new List<Operations_Team_Member__c >();
         List<Upload_Center__c > ucList = new List<Upload_Center__c >();
         List<ID> conIdList = new List<ID>();
         List<ID> userIdList = new List<ID>();
         List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c >();
         string tempContent = '';
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
             otmList = [SELECT id,User_Name__c,Operations_Team__r.Event_Series__c FROM Operations_Team_Member__c WHERE Operations_Team__r.Event_Series__c =:posId
                                                                                               AND User_Name__r.Profile.Name = 'Company Communities User Custom'];
         }
         system.debug('otmList ==='+otmList);
         if(otmList.size()>0 || (Test.isRunningTest())){
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
         
         if(userIdList.size()>0 || (Test.isRunningTest())){
            Contact con = [select Email, id, Name,Type__c,FirstName from Contact where id in: conIdList limit 1];
            List<User> userList = [select Email, id, Name from User where id in: userIdList];
            //EmailTemplate et=[select id,Name from EmailTemplate where name = 'UploadCenterEmail_ForOpsAdmin' limit 1];
            List<Messaging.SingleEmailMessage> massEmailLst= new List<Messaging.SingleEmailMessage>();
            for (User u: userList){
                //system.debug('UserEmail==='+u.email);
                //system.debug('UserName==='+u.name);
                if(eeeTemplateList!=null && eeeTemplateList.size()>0 )
                {
                    tempContent = eeeTemplateList[0].Content__c.replaceAll('\\{Operation_Admin_Name\\}',u.name);tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c,ucId); tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, con.id);tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, con.AccountId); }
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();email.setToAddresses(new String[] {u.email});email.setSaveAsActivity(false); email.setTargetObjectId(u.Id);// email.setTemplateId(et.id);email.setHtmlBody(tempContent); email.setSubject(eeeTemplateList[0].Subject__c);massEmailLst.Add(email);
                
            }       
            system.debug('massEmailLst==='+massEmailLst);
            if(massEmailLst.size()>0) Messaging.sendEmail(massEmailLst);
         }
    }
      
    // This function is used to send Email to contact
    public void sendEmailToCustomer(String UCId, String AttId, String AttName, String eventEditionId)     
    {   
        List<Upload_Center__c > ucList = new List<Upload_Center__c >();
        List<Event_Edition_Email_Template__c> eeeTemplateList = new List<Event_Edition_Email_Template__c >();
        string tempContent = '';
        
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
                //tempContent= ParsePlaceholders.renderTemplate(eeeTemplateList[0].Content__c,eeeTemplateList[0].Event_Edition__c);
                tempContent= ParsePlaceholders.renderTemplate(eeeTemplateList[0].Content__c,eeeTemplateList[0].Event_Edition__c,ucList[0].id );// added by amish (ucLIst[0].id part only)
                tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, ucList[0].Contact__c); // added by amish
                tempContent= ParsePlaceholders.renderTemplate(tempContent,eeeTemplateList[0].Event_Edition__c, ucList[0].Contact__r.AccountID);
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
      
  // This function is used to update theIs_Filled_Up__c field in User_Form_Action__c custom object record for selected UCId
    public void updateUserFormAction(String ufaID){
        List <User_Form_Action__c> ufaList = new List<User_Form_Action__c>();
        List <User_Form_Action__c> ufaListUpdate = new List<User_Form_Action__c>();
        if(string.isNotBlank(ufaID)){
            ufaList = [Select id, Name,Is_Filled_Up__c,Status__c from User_Form_Action__c where ID =: ufaID];
        }
        system.debug('ufaList==='+ufaList);
        if(ufaList.size()>0){
            for(User_Form_Action__c ufa:ufaList){
                ufa.Is_Filled_Up__c = true;
                ufa.Status__c=' Pending Approval';
                ufaListUpdate.add(ufa);
            }
                        
        }
        if(ufaListUpdate.size()>0){update ufaListUpdate;}
    }
      
    // This function is used to update the uploaded attachment data in Upload_Center__c custom object record for selected UCId
    public void updateAttOnUploadCenter(String UCId, String AttId, String AttName)     
    { 
        if(string.isNotBlank(UCId) && string.isNotBlank(AttId) && string.isNotBlank(AttName))
        {
            /* Query the recently created Upload Center record and populate the attached Attachment Name, Attachment Id values in 
               the Upload Center's custom fields - Uploaded_Attachment_Id__c, Uploaded_Attachment_Name__c   */ 
               
            Upload_Center__c uploadCenter = [select id, Name, Uploaded_Attachment_Id__c, Uploaded_Attachment_Name__c from Upload_Center__c where id =:UCId];
            uploadCenter.Uploaded_Attachment_Id__c   = AttID;
            uploadCenter.Uploaded_Attachment_Name__c = AttName;
            uploadCenter.Name = AttName;
            update uploadCenter ;
            system.debug('uploadCenter ==='+uploadCenter );
         }
    }
       
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
}