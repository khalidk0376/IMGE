/**
* Created By:       Divaker Singh
* Date :            6/1/2018
* Test Class :      AttachDocumentCtr_Test(Code Cover 100%)
* *************************************************************************
*/
global class AttachDocumentCtr{
    //Method use for save welcome Email header image into document object and used in WelecomeEmailSetting Skuid page 
    webservice static boolean AttachDocumentCtr(String AttachmentId, String sFolderid, String sEventSettingId)
    {
        List<Document> listDocumentToInsert = new List<Document>();
        Map<Id,Event_Settings__c> mapEventSetting;
        Map<Id, Attachment> mapAttachments;
        mapAttachments = new Map<Id, Attachment>([SELECT Id, Body, ContentType FROM Attachment WHERE ParentId =:sEventSettingId]);
        if(mapAttachments.size()>0 && mapAttachments.containsKey(AttachmentId))
        {
            Attachment att = mapAttachments.get(AttachmentId);
            Document oDocument = new Document();
            oDocument.Body = att.Body;
            oDocument.Name = 'CustomerCenterEmailImage';
            oDocument.ContentType = att.ContentType;
            oDocument.FolderId = sFolderid;
            oDocument.IsPublic  = true;
            listDocumentToInsert.add(oDocument);
        }
        if(listDocumentToInsert.size()>0)
            insert listDocumentToInsert;
            
        if(listDocumentToInsert.size()>0 && sEventSettingId !=''){
            mapEventSetting = new Map<Id,Event_Settings__c>([Select Id, Welcome_Email_Banner__c, Organization_Id_Ops_Admin__c FROM Event_Settings__c where Id =:sEventSettingId LIMIT 1]);
            for(Event_Settings__c es : mapEventSetting.values()){
                es.Welcome_Email_Banner__c = listDocumentToInsert[0].Id;
                es.Organization_Id_Ops_Admin__c = UserInfo.getOrganizationId();
            }
            if(mapEventSetting.size()>0)
                update mapEventSetting.values();
            if(mapAttachments.size()>0)
                delete mapAttachments.values();
        }
        return true;
    }
}