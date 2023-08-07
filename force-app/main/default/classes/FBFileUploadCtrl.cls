/**
 * Created/Modified By: Girikon(Mahesh)
 * Created On:          28 June 2018
 * Description/Purpose: Using in Skuid Page 
 * Test Class:   FBFileUploadCtrl_Test 
 * Code Coverage: 100%
 * Modification log --RKY BK-10852/50
 * Modified By: {Girikon(Mahesh Kumar)} [Jira CCEN--442]} {Girikon(Rajeev Mishra)} [Jira BK-3189],[Aishwarya BK-3780 12 June 2020]}
 * Modified On: 05/12/2018
 * * Modification BY --RKY BK-10852/50
**/
public with sharing class FBFileUploadCtrl 
{    
    //saving the chunk.
    @AuraEnabled
    public static Id saveChunk(String questionId, String questionerId, String accountId, String fileName, String base64Data, String contentType, String fileId,String fileDescription) {
        //create empty response
        //NewCreateTemplateCtr.saveEmpatyResponse(questionerId);
        
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert, 
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with reamins chunks  
        if (fileId == '') {
            String parentId = getReponseId(questionId,questionerId,accountId);
            system.debug('test'+parentId);
            fileId = saveTheFile(parentId, fileName, base64Data, contentType,fileDescription);
        } 
        else{
            appendToFile(fileId, base64Data);
        }
        return Id.valueOf(fileId);
    }
    // Saving the File in attachment. 
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType,String fileDescription) {
        system.debug('FBFileUploadCtrl----***************> ' + parentId +','+ fileName +','+ fileDescription +','+ contentType +','+ base64Data); 
        /*base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8'); 
        Attachment attObj = new Attachment();        
        if(Schema.SObjectType.Attachment.Fields.ParentId.isCreateable()){
            attObj.ParentId = parentId;
        }
        if(Schema.SObjectType.Attachment.Fields.Description.isCreateable()){
            attObj.Description = fileDescription;
        }
        if(Schema.SObjectType.Attachment.Fields.Body.isCreateable()){
            attObj.Body = EncodingUtil.base64Decode(base64Data);
        }
        if(Schema.SObjectType.Attachment.Fields.Name.isCreateable()){
            attObj.Name = fileName;
        }
        if(Schema.SObjectType.Attachment.Fields.ContentType.isCreateable()){
            attObj.ContentType = contentType;
        }
        if(Schema.SObjectType.Attachment.isCreateable()){
            insert attObj;
        }*/
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = fileName;//File name with extention
        cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        cVersion.OwnerId = Userinfo.getUserId();//Owner of the file
        cVersion.Title = fileName;//Name of the file
        //cVersion.FileType = ContentType;
        cVersion.Description = fileDescription;
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        cVersion.VersionData =  EncodingUtil.base64Decode(base64Data);//File content
        insert cVersion;

        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId = parentId;//Add attachment parentId
        cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        insert cDocLink;
        system.debug('cDocLink.ContentDocumentId >: ' + cDocLink.ContentDocumentId);
        
        //Inserting for the Public URL
        ContentDistribution cd = new ContentDistribution();
        cd.Name = fileName;
        cd.ContentVersionId = cVersion.id;
        cd.PreferencesAllowViewInBrowser= true;
        cd.PreferencesLinkLatestVersion=true;
        cd.PreferencesNotifyOnVisit=false;
        cd.PreferencesPasswordRequired=false;
        cd.PreferencesAllowOriginalDownload= true;
        cd.PreferencesAllowPDFDownload = false;
        insert cd;
        system.debug('cd-------- >: ' + cd.ID);
 
        return cDocLink.ContentDocumentId;
    }
    // Querying on attachment for append to File. 
    private static void appendToFile(Id fileId, String base64Data) {
        system.debug('fileId----***************> ' + fileId);
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        if(FBUtils.isAccessible('ContentVersion','Id,VersionData')){ 
            ContentVersion cV = [SELECT PathOnClient,Title,Description,VersionData,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =:fileId];     
            system.debug('fileId----***************> ' + fileId);
            String existingBody = EncodingUtil.base64Encode(cV.VersionData);
            if(Schema.SObjectType.ContentVersion.Fields.VersionData.isUpdateable()){
                cV.VersionData = EncodingUtil.base64Decode(existingBody + base64Data);  
                system.debug('cV.Body----***************> ' + cV.VersionData);
            }
            if(Schema.SObjectType.ContentVersion.isUpdateable()){
                system.debug('cV----***************> ' + cV);
                update cV;
            }
        }
        /*if(FBUtils.isAccessible('Attachment','Id,Body')){ 
            Attachment a = [SELECT Id, Body FROM Attachment WHERE Id =:fileId];     
            String existingBody = EncodingUtil.base64Encode(a.Body);
            if(Schema.SObjectType.Attachment.Fields.Body.isUpdateable()){
                a.Body = EncodingUtil.base64Decode(existingBody + base64Data);     
            }
            if(Schema.SObjectType.Attachment.isUpdateable()){
                update a;
            }
        }*/
    }
     //Getting the responce ID from query if exist then return id otherwise create a new response using loggedin user
    private static String getReponseId(String questionId,String questionerId,String accountId)
    {
        //BK-3780
        String objectName ='Question_Response__c';
        String flsFields ='';
        String query ='';
        String userId = UserInfo.getUserId(); 
        User acc =[select id,name,user.AccountId from user where id=:userId];
        string accid =acc.AccountId;
        
        query = 'Select Id from Question_Response__c WHERE Question__c=\''+String.escapeSingleQuotes(questionId)+'\'';
        if(accid != null && accid !=''){
          query +=  'AND User__r.AccountId=\''+accid+'\'';
        }
        else{
            query +=  'AND User__r.AccountId=\''+accountId+'\'';
        }
        
        List<sObject> objList = FBUtils.getRecords('Question_Response__c', 'Id,User__c,Question__c', query);
        
        // if response exist then return id otherwise create a new response using loggedin user
        
        if(objList.size()>0)
        {
            system.debug('existing Data');
            return String.valueOf(objList[0].get('Id'));    
        }
        else
        {
            /*BK-3189*/
            system.debug('Creating New Data');
            List<FBUtils.KeyValuePair> listObj = new List<FBUtils.KeyValuePair>();
            listObj.add(new FBUtils.KeyValuePair('Questionnaire__c',questionerId));
            listObj.add(new FBUtils.KeyValuePair('Question__c',questionId));
            listObj.add(new FBUtils.KeyValuePair('Account__c',accid));
            listObj.add(new FBUtils.KeyValuePair('User__c',UserInfo.getUserId()));
            listObj.add(new FBUtils.KeyValuePair('Answer__c', ''));
            Map<Integer,List<FBUtils.KeyValuePair>> recordsToInsert = new Map<Integer,List<FBUtils.KeyValuePair>>();
            recordsToInsert.put(0,listObj);
            
            FBUtils.FBResponse response = FBUtils.insertRecords('Question_Response__c',recordsToInsert);
            return response.firstRecordId;
        }
    }
    //Added new method regarding [Jira CCEN--442], For getting id and name from Attachment
    @AuraEnabled
    public static list<AttachmentWrapper> getAttcahments(String questionId,String questionerId, String accountId)
    {   
        list<AttachmentWrapper>attwrap =  new list<AttachmentWrapper>(); 
        set<id> contentversionId = new set<Id>();
        //list<Attachment>attList =  new list<Attachment>();
        list<Attachment>attList =  new list<Attachment>();
        string s = 'txt';
        String parentId = getReponseId(questionId,questionerId,accountId);
        system.debug('parentId--->>>>' + parentId);
        List<ContentDocumentLink> lstContentDocumentLink = new List<ContentDocumentLink>([ SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, ShareType FROM ContentDocumentLink  WHERE LinkedEntityId =: parentId]);
        //        SELECT PathOnClient,Title,Description,VersionData,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =:fileId
        if(!lstContentDocumentLink.isEmpty()){
            for(ContentDocumentLink oContentDocumentLink : lstContentDocumentLink){
                contentversionId.add(oContentDocumentLink.ContentDocumentId);
            }
        }
        system.debug('contentversionId--->>>>' + contentversionId);
        if(parentId != '')
        {
            System.debug('parentId==='+parentId);
            //attList = [];
            for(ContentVersion attContentVersion :[SELECT PathOnClient,Title,Description,VersionData,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =:contentversionId] )
            {
                AttachmentWrapper wrap = new AttachmentWrapper();
                wrap.attId = attContentVersion.Id;
                wrap.attName = attContentVersion.Title;
                attwrap.add(wrap);
            }
        }
        System.debug('attwrap==='+attwrap);
        return attwrap; 

    }
      /*Wrapper Class which holds the Name and Body of Attachments*/
    public class AttachmentWrapper 
    {
        @AuraEnabled public String attId ; //base64encode of Attchment body 
        @AuraEnabled public String attName;         // Attchment name
    }

}