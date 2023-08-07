/**
* Created/Modified By: Girikon(Mahesh)
* Created On:          26 Apr 2018
* Description/Purpose: Using for Upload Signature 
* Test Class:   UploadSignatureControllerTest 
* Code Coverage: 95%
* Modified By:{Girikon(Rajeev Mishra)} [Jira BK-3189],[BK-15729]}
* Modification BY --RKY BK-10852/50
**/
public with sharing class UploadSignatureController {
    
    @AuraEnabled
    public static String saveSignatureResponse(String questionId,String questionerId,String base64Data)
    {
         /*BK-3189*/
        FBUtils.FBResponse response = new FBUtils.FBResponse();
        //create empty response
        //NewCreateTemplateCtr.saveEmpatyResponse(questionerId);
        //set user response data
        String userId = UserInfo.getUserId(); 
        User acc=[select id,name,user.AccountId,ContactId, Profile.Name from user where id=:userId LIMIT 1];
        Map<String,Object> fieldMap=new Map<String,Object>();
        List<FBUtils.KeyValuePair> listObj = new List<FBUtils.KeyValuePair>();
        listObj.add(new FBUtils.KeyValuePair('Questionnaire__c',questionerId));
        listObj.add(new FBUtils.KeyValuePair('Question__c',questionId));
        listObj.add(new FBUtils.KeyValuePair('Account__c',acc.AccountId));
        listObj.add(new FBUtils.KeyValuePair('User__c',UserInfo.getUserId()));
        Map<Integer,List<FBUtils.KeyValuePair>> recordsToInsert = new Map<Integer,List<FBUtils.KeyValuePair>>();
        
        String query = 'Select Id,Answer__c,Comment__c,Question__c,Score__c,Questionnaire__c from Question_Response__c WHERE Questionnaire__c=\''+String.escapeSingleQuotes(questionerId)+'\' AND Question__c=\''+String.escapeSingleQuotes(questionId)+'\' AND User__c=\''+UserInfo.getUserId()+'\'';
        List<sObject> objList = FBUtils.getRecords('Question_Response__c', 'Id', query);
        
        if(!objList.isEmpty()){
             //If exist answer by user for same question then upload signature only
            String Id = saveTheFile(String.valueOf(objList[0].get('Id')), base64Data);
            if(Id!=''){
                listObj.add(new FBUtils.KeyValuePair('Id',objList[0].get('Id')));
                listObj.add(new FBUtils.KeyValuePair('Answer__c', '/servlet/servlet.FileDownload?file='+Id));
                recordsToInsert.put(0,listObj);
                FBUtils.updateRecords('Question_Response__c', recordsToInsert);
                //CCEN747 changes Starts..
                for(FBUtils.KeyValuePair  estimatedVal : listObj )
                {
                    fieldMap.put(estimatedVal.fieldName, estimatedVal.fieldValue);
                    if(fieldMap.get('Question__c')!=null)
                    {
                        
                        response.responseValue= '/servlet/servlet.FileDownload?file='+Id;
                        response.responseId= fieldMap.get('Question__c').toString();
                    }
                }
                //CCEN747End..
                response.isSuccess = true;
                response.message = 'Signature uploaded successfully';    
            }else{
                response.isSuccess = false;
                response.message = 'Failed!';
            }
        }
        else
        {
            // create new response for a question
            Map<String,Object> feildVal=new Map<String,Object>();
            recordsToInsert.put(0,listObj);
            response = FBUtils.insertRecords('Question_Response__c', recordsToInsert);
            String Id =  saveTheFile(response.firstRecordId,base64Data);
            recordsToInsert.clear();
            listObj.add(new FBUtils.KeyValuePair('Id',response.firstRecordId));
            listObj.add(new FBUtils.KeyValuePair('Answer__c','/servlet/servlet.FileDownload?file='+Id));
            recordsToInsert.put(0,listObj);
            FBUtils.updateRecords('Question_Response__c', recordsToInsert);
            //CCEN747 changes Starts..
             for(FBUtils.KeyValuePair  estimatedVal : listObj )
            {
                feildVal.put(estimatedVal.fieldName, estimatedVal.fieldValue);
                if(feildVal.get('Question__c')!=null)
                {
                      
                      response.responseValue= '/servlet/servlet.FileDownload?file='+Id;
                      response.responseId= feildVal.get('Question__c').toString();
                }
            }
            //CCEN747End..
            return JSON.serialize(response);
        }
        return JSON.serialize(response);
    }
    
    public static String saveTheFile(Id parentId, String base64Data) { 
        System.debug(base64Data);
        String fileName = UserInfo.getName()+' Signature.png';
        //Delete([Select id from Attachment WHERE Name =: fileName AND ParentId=:parentId AND CreatedById=:UserInfo.getUserId()]);
        
        /*base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');     
        Attachment a = new Attachment();
        a.parentId = parentId;        
        a.Body = EncodingUtil.base64Decode(base64Data);
        a.Name = fileName;
        a.ContentType = 'image/png';
        insert a; */
        
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = fileName;//File name with extention
        cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        cVersion.OwnerId = Userinfo.getUserId();//Owner of the file
        cVersion.Title = fileName;//Name of the file
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
    
}