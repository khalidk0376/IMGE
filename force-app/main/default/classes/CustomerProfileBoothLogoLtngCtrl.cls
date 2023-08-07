/**
* Created/Modified By: Girikon(shashank)
* Created On:          24/08/2017
* @description       : his class is the controller for "CustomerProfileBoothLogo" VF pages
*                      This class uplaod the new logo or update the existing logo at the booth level on customer profile
* Methods:             saveBoothLogo, updateAttOnBoothRecord
* Test Class:          CustomerProfileBoothLogoLtngCtrl_Test(90%)
* Modification Log---
* Modified By:         Girikon(Prashant) [CCEN-743 (April 12 2019), C2E-102 (Sept 24 2019)], [Aishwarya BK-15072 9 Apr 2021]
**/

public without sharing class CustomerProfileBoothLogoLtngCtrl 
{
    // fetchExistingAttachment  --parentId
     @AuraEnabled
    //public static Attachment fetchExistingAttachment(Id parentId)
    public static ContentDocument fetchExistingAttachment(Id parentId)
    {
        List<Opportunity_ExpoCAD_Booth_Mapping__c> ListOppExpo = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
        List<ContentDocument> attList = new List<ContentDocument>();
        ListOppExpo = [Select Booth_Logo_Id__c from Opportunity_ExpoCAD_Booth_Mapping__c where id=:parentId LIMIT 1];
        if(ListOppExpo !=null && ListOppExpo.size()>0 && ListOppExpo[0].Booth_Logo_Id__c != null){
            attList = [Select Id, Title FROM ContentDocument where Id=:ListOppExpo[0].Booth_Logo_Id__c];
        }
        if(attList.size()>0){
            return attList.get(0);
        }
        return null;                               
    }

    //return base URL of sfdc
    @AuraEnabled
    public static String getBaseUrl() 
    {
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        return baseUrl;
    }
    
    // Method will be used for lightning cmp, will update the field on Opportunity_ExpoCAD_Booth_Mapping__c( adding booth logo to the Opportunity_ExpoCAD_Booth_Mapping__c object) [CCEN-743]  
    public static void updateAttOnBoothRecordLightn(String boothId, String attid)     
    { 
        system.debug('boothId== '+boothId);
        system.debug('attid== '+attid);
        if(string.isNotBlank(boothId) && string.isNotBlank(attid))
        {   
            List<Opportunity_ExpoCAD_Booth_Mapping__c> blidLIst = new List<Opportunity_ExpoCAD_Booth_Mapping__c>();
            List<BoothContactInfo__c> boothContactList = new List<BoothContactInfo__c>();
            if(Schema.sObjectType.Opportunity_ExpoCAD_Booth_Mapping__c.isAccessible())
            {            
                blidLIst = [Select Booth_Logo_Id__c from Opportunity_ExpoCAD_Booth_Mapping__c where id=:boothId];
            } 
            if(Schema.sObjectType.BoothContactInfo__c.isAccessible())
            {
                boothContactList = [Select id, Opportunity_Booth_Mapping__c from BoothContactInfo__c where Opportunity_Booth_Mapping__c=:boothId ORDER BY createdDate ASC limit 1];
            }           
            if(blidLIst.size()>0 && !boothContactList.isEmpty()  && Schema.sObjectType.Opportunity_ExpoCAD_Booth_Mapping__c.isUpdateable() && Schema.sObjectType.BoothContactInfo__c.isUpdateable())
            {
                System.debug('update' +boothContactList);
                blidLIst[0].Booth_Logo_Id__c =attid;
                update blidLIst;
                update boothContactList;
            }
        }
    }
    //Fetch event details    
    @AuraEnabled  
    public static Event_Settings__c getEventDetails(String sEventcode)
    {
        return UtilityMethods.getEventDetails(sEventcode); 
    }
    
    // code for lightning component starts here
    // parentId - for boothexpocad id
    // fileName - attachment name 
   @AuraEnabled
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert, 
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with reamins chunks   
        system.debug('======================FILEID'+fileId);
        if (fileId == '') 
        {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } else
        {
            appendToFile(fileId, base64Data);
        }
        return Id.valueOf(fileId);
    }
 
    // added the method updateAttOnBoothRecordLightn for updating the respective records after saving the file[C2E-102] 
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        system.debug('======================PARENTID'+parentId);
        system.debug('======================Filename'+fileName);
        system.debug('======================contenType'+contentType);
        
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        /*
        Attachment oAttachment = new Attachment();
        oAttachment.parentId = parentId;
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = fileName;
        oAttachment.ContentType = contentType;
        insert oAttachment;
        String attachId = oAttachment.Id;
        updateAttOnBoothRecordLightn( parentId, attachId); 
        return oAttachment.Id;
        */

        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = fileName;//File name with extention
        cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        cVersion.OwnerId = Userinfo.getUserId();//Owner of the file
        cVersion.Title = fileName;//Name of the file
        cVersion.VersionData =  EncodingUtil.base64Decode(base64Data);//File content
        //cVersion.VersionData = EncodingUtil.base64Decode(base64Data);//File content
        insert cVersion;
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId = parentId;//Add attachment parentId
        cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        insert cDocLink;
        
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
        
        updateAttOnBoothRecordLightn( parentId, cDocLink.ContentDocumentId); 
        //return conDocument;
        return cDocLink.ContentDocumentId;
       // return oAttachment.Id;
        
    }
 
    @TestVisible
    private static void appendToFile(Id fileId, String base64Data) {
        // Added by Palla Kishore for the ticket BK-19604
        system.debug('appendToFile Method is Invoked');
    /**
        system.debug('======================FILEID22'+fileId);
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        system.debug('================'+fileId);
        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id =: fileId
        ];
 
        String existingBody = EncodingUtil.base64Encode(a.Body);
 
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
     */
       // update a;
    }
   
    /*
    @AuraEnabled
    public static void delPreviousAttachment(String attachId ,String parentId)
    {
        //Map<id , Attachment>  mapAttchDb = new Map<id , Attachment>([Select Id from Attachment where parentId =:parentId ]);
        Map<id , ContentDocumentLink>  mapAttchDb = new Map<id , ContentDocumentLink>([Select ContentDocumentId from ContentDocumentLink where LinkedEntityId =:parentId]);
        if(mapAttchDb != NULL && !mapAttchDb.isEmpty())
        { 
            if(mapAttchDb.containsKey(attachId))
            {
                mapAttchDb.remove(attachId);                
            }
        }
         if(mapAttchDb != NULL && (!mapAttchDb.isEmpty()) && (mapAttchDb.size()>0) )
         {
            //List<Attachment> listAttch = new List<Attachment>(mapAttchDb.values());
            List<ContentDocumentLink> listAttch = new List<ContentDocumentLink>(mapAttchDb.values());
            delete listAttch;
         }
          updateAttOnBoothRecordLightn( parentId, attachId);                          
    }
    */
}