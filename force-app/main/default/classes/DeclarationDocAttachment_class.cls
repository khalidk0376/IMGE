/**
* Project:     GAP
* Date:        25/04/2019
* Created By:  Rajesh Kumar
* Test Class:  DeclarationDocAttachmentcls_test
* *************************************************************************
* @Description Visible only Declaration Doc Attachment on opportunity
* *************************************************************************
* History:
*/

public with sharing class DeclarationDocAttachment_class {
    
    @AuraEnabled
    public static AttachmentControllerWrapper getAttachments(String ParentId ,Decimal pageNumber, Decimal pageSize) {
        System.debug('Test Debug log : ' + ParentId);
        Integer pSize = (Integer)pageSize;
        Integer pNumber = (Integer)pageNumber;
        
        //Offset for SOQL
        Integer offset = (pNumber - 1) * pSize;
        
        //Total Records
        Set<Id> sids = new Set<Id>();
        List <ContentDocumentLink> lstContentDocumentLink = [SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, ShareType FROM ContentDocumentLink  where LinkedEntityId =: ParentId ]; 
        for (ContentDocumentLink ocontentdocuments : lstContentDocumentLink){
            sids.add(ocontentdocuments.ContentDocumentId);
        }
        Integer totalRecords = [SELECT COUNT() FROM ContentVersion  Where ContentDocumentId = : sids AND (PathOnClient LIKE '%Declaration Document%' or Title LIKE '%Declaration Document%') ];
        Integer recordEnd = pSize * pNumber;
        
        //Instance of Contact DataTable Wrapper Class
        AttachmentControllerWrapper objDT =  new AttachmentControllerWrapper();  
        objDT.pageSize = pSize;
        objDT.pageNumber = pNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        system.debug('totalRecords' + totalRecords);
        // objDT.contactList = [SELECT Id, Name, Phone, Email FROM Contact ORDER BY Name LIMIT :pSize OFFSET :offset];
        objDT.attachmentList = [SELECT Id, Title, PathOnClient, OwnerId, Owner.Name , CreatedDate, CreatedBy.Profile.Name , ContentDocumentId FROM ContentVersion  Where ContentDocumentId = : sids AND Title LIKE '%Declaration Document%' ORDER BY LastModifiedDate DESC LIMIT :pSize OFFSET :offset];
        return objDT;
    }
    @AuraEnabled
    public static void getAttachmentDel(string AttachmentDelId) {
        System.debug('Testing : AttachmentDelId '+AttachmentDelId);
        List<ContentDocument> lstContentDocument = [SELECT Id,Title, ParentId From ContentDocument where Id =: AttachmentDelId ];
        System.debug('Testing : '+lstContentDocument);
        List<ContentDocumentLink> lstContentDocumentLink= [SELECT Id, LinkedEntityId, ContentDocumentId, IsDeleted, LinkedEntity.Type FROM ContentDocumentLink where ContentDocumentId =: AttachmentDelId];
        System.debug('Testing : '+lstContentDocumentLink);
        String pid;
        
        for(ContentDocumentLink Id2: lstContentDocumentLink){
            if(Id2.LinkedEntity.Type == 'Opportunity'){
                pid=Id2.LinkedEntityId;
            }
        }
        System.debug('PID='+ pid);
        List<Opportunity> Id4=new List<Opportunity>();
        List<Opportunity> Id1=[SELECT Id From Opportunity where Id =: pid];
        
        for(Opportunity Id5: Id1){
           Opportunity Id6=new Opportunity();
            Id6.Id=Id5.Id;
            Id6.Declaration_Document_Uploaded__c=False;
            Id6.Declaration_Document_Link__c = '';
            Id4.add(Id6);
            
            }
        if(!Id4.isEmpty())        {
            
        if (!lstContentDocument.isEmpty())
        {    
           
            Delete lstContentDocument;
            System.debug('Documents Getting Deleted ' );
            
        }
            update Id4;
        }
       
    }
    
    public static pagereference getAttachmentView(string AttachmentView){
        pagereference newTab=new pagereference(URL.getSalesforceBaseUrl().toExternalForm() +'/sfc/servlet.shepherd/version/download/'+AttachmentView+'?asPdf=false&operationContext=CHATTER');
        return newTab;
    }
    
    @AuraEnabled
    public static Map<String, Object> getProfileName(){
        String loggedInUserProfileName = [Select Name from Profile WHERE id=:UserInfo.getProfileId()].Name;        
        List<AllowedProfiles__c> allowedProfileList = [Select Id from AllowedProfiles__c WHERE Name =:loggedInUserProfileName];
        return new Map<String, Object>{
            'profile'=>allowedProfileList.size()>0?true:false
    	};
    }
    
    //Wrapper Class For Contact DataTable  
    public class AttachmentControllerWrapper {
        @AuraEnabled
        public Integer pageSize {get;set;}
        @AuraEnabled
        public Integer pageNumber {get;set;}
        @AuraEnabled
        public Integer totalRecords {get;set;}
        @AuraEnabled
        public Integer recordStart {get;set;}
        @AuraEnabled
        public Integer recordEnd {get;set;}
        @AuraEnabled
        public List<ContentVersion> attachmentList {get;set;}
    }
}