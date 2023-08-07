/**
* Project:     GAP
* Date:        25/04/2019
* Created By:  Rajesh Kumar
* Test Class:  FileUploadController_Test
* *************************************************************************
* @description file upload funcationality in Account , Contact and Opportunity .
* *************************************************************************
* History:BK-1232 Date 25/07/2019 By Rajesh Kr
*/

public with sharing class FileUploadController_class {  
    @AuraEnabled
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert, 
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with reamins chunks   
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } else {
            appendToFile(fileId, base64Data);
        }
 
        return Id.valueOf(fileId);
    }
 
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Attachment oAttachment = new Attachment();
        oAttachment.parentId = parentId;
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = fileName;
        oAttachment.ContentType = contentType;
        insert oAttachment;
        return oAttachment.Id;
    }
 
    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id =: fileId
        ];
        String existingBody = EncodingUtil.base64Encode(a.Body);
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
        update a;
    }
    
    @AuraEnabled
    public static Id editData (Id attachmentId , Id parentId, Boolean isPrivate){
        Attachment editAttachment = [Select IsPrivate, ParentId, Id from Attachment where Id=:AttachmentId];
        editAttachment.IsPrivate = isPrivate;
        update editAttachment;
        return editAttachment.Id;     
    }
    
    @AuraEnabled
    public static AttachmentControllerWrapper getAttachments(String parentId ,Decimal pageNumber, Decimal pageSize) {
        System.debug('Test Debug log : ' + parentId);
        Integer pSize = (Integer)pageSize;
        Integer pNumber = (Integer)pageNumber;
        
        //Offset for SOQL
        Integer offset = (pNumber - 1) * pSize;
        
        //Total Records
        Integer totalRecords = [SELECT COUNT() FROM Attachment Where parentId = : parentId AND (NOT Name LIKE '%Declaration Document%')];
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
        objDT.attachmentList = [SELECT Id, Name, ContentType, IsPrivate, CreatedById, CreatedBy.Name , CreatedDate FROM Attachment Where parentId = : parentId AND (NOT Name LIKE '%Declaration Document%') ORDER BY createdDate DESC LIMIT :pSize OFFSET :offset];
        
        return objDT;
    }
    
    @AuraEnabled
    public static void getAttachmentDel(string attachmentDelId) {
        List<Attachment> listdata= [SELECT id,Name FROM Attachment Where Id = : AttachmentDelId];
        if(listdata.size() > 0){
            delete listdata;
        }
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
        public List<Attachment> attachmentList {get;set;}
    }
}