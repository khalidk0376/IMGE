/**
 * Created/Modified By: Girikon(Archit)
 * Created On:          7/6/2017
 * Description/Purpose: This class is called through the VF page: UploadCenter for the Skuid page - CustomerUploadCenter
 * Methods:             upload, updateAttOnUploadCenter
 * Test Class:          EditUploadCenter_Test
 **/
 
public class EditUploadCenter
{
    public string nameFile{get;set;}
    public Blob contentFile{get;set;}
    String[] filelines = new String[]{};
    List<Attachment> attachementList;
    public string eventCodeFromURl;
    public string uploadCenterId;
    public string userActionForm_FromURl;
    public string partOfSeries_FromURl;
    public boolean check {get;set;}
    public Upload_Center__c uploadCenter;
    public Id eventEditionId;
    public Attachment attachment {
      get {
          if (attachment == null)
            attachment = new Attachment();
          return attachment;
          }
      set;
      }

    /*** Function that uplaods file for the Upload_Center__c custom object. ***/
  
     
      public PageReference upload() {

        eventCodeFromURl = ApexPages.currentPage().getParameters().get('eventCode').escapeHtml4();
        uploadCenterId = ApexPages.currentPage().getParameters().get('UCId').escapeHtml4();
        userActionForm_FromURl = ApexPages.currentPage().getParameters().get('ufaID').escapeHtml4();
        partOfSeries_FromURl= ApexPages.currentPage().getParameters().get('posId').escapeHtml4();
        system.debug('partOfSeries_FromURl === '+partOfSeries_FromURl);
        check =false;
        attachment.OwnerId = UserInfo.getUserId();
        attachment.ParentId = uploadCenterId ; // the record the file is attached to
        //attachment.IsPrivate = true;
    
        try {
          insert attachment;
          attachementList = [Select Id, Name from Attachment where parentID =:uploadCenterId ORDER BY CreatedDate DESC Limit 1];
          updateAttOnUploadCenter(uploadCenterId,attachementList[0].Id,attachementList[0].Name);
          if(string.isNotBlank(userActionForm_FromURl)) updateUserFormAction(userActionForm_FromURl);
              /* Commented as we are referring to custom email templates only
                  sendEMail(uploadCenterId,attachementList[0].Id,attachementList[0].Name);
                  sendEmailToOpsAdmin(partOfSeries_FromURl,uploadCenterId,attachementList[0].Id,attachementList[0].Name);
              */
          /*PageReference redirectPage = new PageReference('/c__ContractorUploadCenter?eventCode=' + eventCodeFromURl);
          redirectPage.setRedirect(true);
          return redirectPage;*/
         // return new PageReference('javascript:window.close();');
        } 
        catch (DMLException e) {
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error in uploading the attachment'));
          return null;
        } 
        finally {
          attachment = new Attachment(); 
        }
    
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully. Please close this window.'));
        check = true;
        return null;
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
       
      
}