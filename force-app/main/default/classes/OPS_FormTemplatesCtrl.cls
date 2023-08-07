/*
Created By      : Girikon(Garima[STL-39])
Created On      : August 19 2019, [Aishwarya BK-14398 18 March 2021]
@description    : This class is used to update the two fields on Forms after uploading the Attachment.
Test Class      : OPS_FormTemplatesCtrl_Test(Coverage 94%)

Modification log --
Modified By     : [Aishwarya June 7 2020 BK-4682]
*/
public with sharing class OPS_FormTemplatesCtrl {
    
     /**
     * @description [update Attach On Form]
     * @param  formId [Form Id to which attached is updated]
     * @param  attId [Attachment id]
     * @param  attName [Name of the attachement that need to be updated ]
     * @return          [Void ]
     */
     @AuraEnabled
     public static void updateAttachOnForm(String formId,String attId,String attName)
     {
     if(string.isNotBlank(formId) && string.isNotBlank(attId) && string.isNotBlank(attName))
        {
            /* Query the recently created Form record and populate the attached Attachment Name, Attachment Id values in 
               the Form's custom fields - Uploaded_Attachment_Id__c, Uploaded_Attachment_Name__c   */ 
               
            Form__c form = [select id, Uploaded_Attachment_Id__c, Uploaded_Attachment_Name__c 
                            from Form__c
                            where id =:formId];
            
            form.Uploaded_Attachment_Id__c   = attId;
            form.Uploaded_Attachment_Name__c = attName;
            update form;
         }
     }
    
    /**
     * @description [update and delete Attach On Form]
     * @param  formId [Form Id to which attached is updated]
     * @param  attId [Attachment id]
     * @param  attName [Name of the attachement that need to be updated ]
     * @return          [Void ]
     */
     @AuraEnabled 
     public static void updateAndDeleteAttOnForm(String formId, String attId, String attName ) 
    { 
        // update recent added attachment(when editing the Form record and upload a file) details on the form's fields i.e Uploaded_Attachment_Id__c, Uploaded_Attachment_Name__c 
        if(string.isNotBlank(formId) && string.isNotBlank(attId) && string.isNotBlank(attName))
        {
            Form__c form = [select id, Uploaded_Attachment_Id__c, Uploaded_Attachment_Name__c 
                            from Form__c 
                            where id =:formId];
            if(String.IsNotBlank(form.Uploaded_Attachment_Id__c))
            {
                List<ContentDocument> docmList = new List<ContentDocument>();
                docmList = [Select Id ,Title 
                            from ContentDocument 
                            Where Id =: form.Uploaded_Attachment_Id__c];
                if(docmList != null && docmList.size()>0)
                    Database.delete(docmList,false);        //BK-14398
            }
            form.Uploaded_Attachment_Id__c   = attID; 
            form.Uploaded_Attachment_Name__c = attName;
            update form;
         }
    }

    
     /**
     * @description [get content version id of documrnt ]
     * @param  docId [document id for which content version Id should be fetched  ]
     * @return          [ content version id of  document]
     */
    @AuraEnabled 
     public static ContentVersion getContentVersionId(String docId) {
         //To fetch the content version Id of respective content document
         ContentVersion conVer = new ContentVersion();
         if(string.isNotBlank(docId)) {
         conVer = [SELECT Id,Title 
                   FROM ContentVersion 
                   WHERE ContentDocumentId =: docId];
         }
         return conVer;
     }

     /**
     * @description [update Attach On Manuals]
     * @param  ManualId [Manual  Id for which attached is updated]
     * @param  attId [Attachment id]
     * @param  attName [Name of the attachement that need to be updated ]
     * @return          [Void ]
     */
     @AuraEnabled
     public static void updateAttachOnManual(String ManualId, String AttId, String AttName){
     if(string.isNotBlank(ManualId) && string.isNotBlank(AttId) && string.isNotBlank(AttName))
        {
            /* Query the recently created Form record and populate the attached Attachment Name, Attachment Id values in 
               the Form's custom fields - Uploaded_Attachment_Id__c, Uploaded_Attachment_Name__c   */ 
               
            Manual__c manual = [select id, Uploaded_Attachment_Id__c, Uploaded_Attachment_Name__c, Content_Version_Id__c
                                from Manual__c  
                                where id =:ManualId];
            manual.Uploaded_Attachment_Id__c   = AttID;
            manual.Uploaded_Attachment_Name__c = AttName;
            // added BK-4682
            if(String.IsNotBlank(AttId))
            {
                List<ContentVersion> docmList = new List<ContentVersion>();
                docmList = [select id FROM ContentVersion where contentdocumentid =: AttId];
                if(docmList != null && docmList.size()>0)
                   manual.Content_Version_Id__c = docmList[0].Id;      
            }
            update manual;
         }

     }
     @AuraEnabled 
     public static void updateAndDeleteAttOnManual(String ManualId, String AttID, String AttName ) 
    { 
        // update recent added attachment(when editing the Form record and upload a file) details on the form's fields i.e Uploaded_Attachment_Id__c, Uploaded_Attachment_Name__c 
        if(string.isNotBlank(ManualId) && string.isNotBlank(AttID) && string.isNotBlank(AttName))
        {
            Manual__c manual = [select id, Uploaded_Attachment_Id__c, Uploaded_Attachment_Name__c 
                                from Manual__c 
                                where id =:ManualId];
            if(String.IsNotBlank(manual.Uploaded_Attachment_Id__c))
            {
                List<ContentDocument> docmList = new List<ContentDocument>();
                docmList = [Select Id ,Title 
                            from ContentDocument 
                            Where Id =: manual.Uploaded_Attachment_Id__c];
                if(docmList != null && docmList.size()>0)
                    Database.delete(docmList,false);        //BK-14398
            }
            manual.Uploaded_Attachment_Id__c = AttID; 
            manual.Uploaded_Attachment_Name__c = AttName;
            // added BK-4682
            if(String.IsNotBlank(AttId))
            {
                List<ContentVersion> docmList = new List<ContentVersion>();
                docmList = [select id FROM ContentVersion where contentdocumentid =: AttId];
                if(docmList != null && docmList.size()>0)
                   manual.Content_Version_Id__c = docmList[0].Id;      
            }
            update manual;
         }
    }
    
}