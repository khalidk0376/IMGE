/**
 * Created/Modified By: Girikon(Aishwarya)
 * Created On:          5/29/2017
 * Description/Purpose: This class is called through the Skuid pages - Form_List and Manual_List
 * Methods:             updateAttOnManual, deleteAttOnManual, updateAttOnForm, updateAndDeleteAttOnForm, updateAndDeleteAttOnManual
 * Test Class:          updateAttFieldsOnFormAndManual_Test
**/
 
global class updateAttFieldsOnFormAndManual
{
    webservice static void updateAttOnManual(String ManualId, String AttId, String AttName) 
    { 
        // check the above parameters are not blank.                 
        if(string.isNotBlank(ManualId) && string.isNotBlank(AttId) && string.isNotBlank(AttName))
        {
            /* Query the recently created Manual record and populate the attached Attachment Name, Attachment Id values in 
               the Manual's custom fields - Uploaded_Attachment_Id__c, Uploaded_Attachment_Name__c  */
               
            Manual__c manual = [select id, Uploaded_Attachment_Id__c, Uploaded_Attachment_Name__c from Manual__c where id =:ManualId];
            manual.Uploaded_Attachment_Id__c   = AttID;
            manual.Uploaded_Attachment_Name__c = AttName;
            update Manual;
         }
    } 
    
    webservice static void deleteAttOnManual(String ManualId) 
    { 
         // For deleting the Manual record having "No Attachment Id"
         if(string.isNotBlank(ManualId))
         {
             Manual__c manual = [select id from Manual__c where id =:ManualId];
             delete manual;
         }
    }
    
    webservice static void updateAttOnForm(String FormId, String AttId, String AttName)     
    { 
        if(string.isNotBlank(FormId) && string.isNotBlank(AttId) && string.isNotBlank(AttName))
        {
            /* Query the recently created Form record and populate the attached Attachment Name, Attachment Id values in 
               the Form's custom fields - Uploaded_Attachment_Id__c, Uploaded_Attachment_Name__c   */ 
               
            Form__c form = [select id, Uploaded_Attachment_Id__c, Uploaded_Attachment_Name__c from Form__c where id =:FormId];
            form.Uploaded_Attachment_Id__c   = AttID;
            form.Uploaded_Attachment_Name__c = AttName;
            update form;
         }
    }
    
    webservice static void updateAndDeleteAttOnForm(String FormId, String AttId, String AttName ) 
    { 
        // update recent added attachment(when editing the Form record and upload a file) details on the form's fields i.e Uploaded_Attachment_Id__c, Uploaded_Attachment_Name__c 
        if(string.isNotBlank(FormId) && string.isNotBlank(AttId) && string.isNotBlank(AttName))
        {
            Form__c form = [select id, Uploaded_Attachment_Id__c, Uploaded_Attachment_Name__c from Form__c where id =:FormId];
            if(String.IsNotBlank(form.Uploaded_Attachment_Id__c))
            {
                List<Attachment> listAttachment = [SELECT Id FROM Attachment where Id =: form.Uploaded_Attachment_Id__c];
                if(listAttachment != null && listAttachment.size()>0)
                    delete listAttachment;        
            }
            form.Uploaded_Attachment_Id__c   = AttID; 
            form.Uploaded_Attachment_Name__c = AttName;
            update form;
         }
    }
    
    webservice static void updateAndDeleteAttOnManual(String ManualId, String AttId, String AttName ) 
    { 
        // update recent added attachment(when editing the Manual record and upload a file) details on the manual's fields i.e Uploaded_Attachment_Id__c, Uploaded_Attachment_Name__c 
        if(string.isNotBlank(ManualId) && string.isNotBlank(AttId) && string.isNotBlank(AttName))
        {
            Manual__c manual = [select id, Uploaded_Attachment_Id__c, Uploaded_Attachment_Name__c from Manual__c where id =:ManualId];
            if(String.IsNotBlank(manual.Uploaded_Attachment_Id__c))
            {
                List<Attachment> listAttachment = [SELECT Id FROM Attachment where Id =: manual.Uploaded_Attachment_Id__c];
                if(listAttachment != null && listAttachment.size()>0)
                    delete listAttachment;        
            }
            manual.Uploaded_Attachment_Id__c   = AttID; 
            manual.Uploaded_Attachment_Name__c = AttName;
            update manual;
         }
    }
}